//
//  LogRepository.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import FirebaseFirestore
import Foundation

class LogRepository {
    
    static func addLog(name: String, isVisible: Bool, ownerId: String) async -> Result<Bool, Error> {
        do {
            let date = String(currentTimeInMS())
            let ownerData = Owner(userId: ownerId, priority: 0)
            let logData = LogData(
                name: name,
                creationDate: date,
                lastModifiedDate: date,
                isVisible: isVisible,
                owner: ownerData,
                movieIds: [:],
                watchedIds: [:],
                collaborators: [:]
            )
            let result = try await FirebaseService.shared.post(data: logData, collection: "logs").get()
            
            // Update log to include logId
            _ = try await FirebaseService.shared.put(updates: ["log_id": result], docId: result, collection: "logs").get()
            
            return .success(true)
        } catch {
            return .failure(error)
        }
    }
    
    // TODO: Append movie data
    static func getLog(logId: String) async -> Result<LogData, Error> {
        do {
            let result = try await FirebaseService.shared.get(type: LogData(), docId: logId, collection: "logs").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    // TODO: Get first movie id, add half sheet
    static func getLogs(userId: String, showPrivate: Bool) async -> Result<[LogData], Error> {
        do {
            let logRef = FirebaseService.shared.db.collection("logs")
            let logData: [LogData] = try await withThrowingTaskGroup(of: [LogData].self) { group in
                // Query for user-owned logs
                group.addTask {
                    do {
                        let q = if (showPrivate) {
                            logRef.whereField("owner.user_id", isEqualTo: userId)
                        } else {
                            logRef.whereField("owner.user_id", isEqualTo: userId).whereField("is_visible", isEqualTo: true)
                        }
                        return try await FirebaseService.shared.getBatch(type: LogData(), query: q).get()
                    } catch {
                        throw error
                    }
                }
                
                // Query for user in collaborators
                group.addTask {
                    do {
                        let q = if (showPrivate) {
                            logRef.order(by: "collaborators.\(userId)")
                        } else {
                            logRef.order(by: "collaborators.\(userId)").whereField("is_visible", isEqualTo: true)
                        }
                        return try await FirebaseService.shared.getBatch(type: LogData(), query: q).get()
                    } catch {
                        throw error
                    }
                }
                
                var resultArr: [LogData] = []
                
                for try await result in group {
                    resultArr.append(contentsOf: result)
                }
                
                return resultArr
            }
            
            return .success(logData)
        } catch {
            return .failure(error)
        }
    }
    
    static func updateLog(logId: String, updateData: [String: Any]) async -> Result<Bool, Error> {
        do {
            var updateDataObj: [String: Any] = updateData
            updateDataObj["last_modified_date"] = String(currentTimeInMS())
            
            let result = try await FirebaseService.shared.put(updates: updateDataObj, docId: logId, collection: "logs").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func deleteLog(logId: String) async -> Result<Bool, Error> {
        do {
            let result = try await FirebaseService.shared.delete(doc: LogData(), docId: logId, collection: "logs").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func updateUserLogOrder(userId: String, logIds: [(String, Bool)]) async -> Result<Bool, Error> { // Boolean represents whether user owns this log
        do {
            let result = try await withThrowingTaskGroup(of: Bool.self) { group in
                for (index, item) in logIds.enumerated() {
                    let updates = if (item.1) {
                        ["owner.priority": index]
                    } else {
                        ["collaborators.\(userId).priority": index]
                    }
                    
                    group.addTask {
                        do {
                            return try await FirebaseService.shared.put(updates: updates, docId: userId, collection: "logs").get()
                        } catch {
                            throw error
                        }
                    }
                }
                
                for try await result in group {
                    if (!result) {
                        throw FirebaseError.failedTransaction
                    }
                }
                
                return true
            }
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func addCollaborators(logId: String, collaborators: [String]) async -> Result<Bool, Error> {
        do {
            var collabs: [String: [String: Int]] = [:]
            for collaborator in collaborators {
                collabs["collaborators.\(collaborator)"] = ["priority": 0]
            }
            
            let result = try await FirebaseService.shared.put(updates: collabs, docId: logId, collection: "logs").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func removeCollaborators(logId: String, collaborators: [String]) async -> Result<Bool, Error> {
        do {
            var collabs: [String: Any] = [:]
            for collaborator in collaborators {
                collabs["collaborators.\(collaborator)"] = FieldValue.delete()
            }
            
            let result = try await FirebaseService.shared.put(updates: collabs, docId: logId, collection: "logs").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
}
