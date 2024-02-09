//
//  FriendRepository.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import FirebaseFirestore
import Foundation

class FriendRepository {
    static func addLogRequest(senderId: String, targetId: String, logId: String, requestDate: String) async -> Result<Bool, Error> {
        do {
            let logRequestData = LogRequestData(senderId: senderId, targetId: targetId, logId: logId, requestDate: requestDate, isComplete: false)
            let result = try await FirebaseService.shared.post(data: logRequestData, collection: "log_requests").get()
            
            // Update log request to include request id
            _ = try await FirebaseService.shared.put(updates: ["request_id": result], docId: result, collection: "log_requests").get()
            
            return .success(true)
        } catch {
            return .failure(error)
        }
    }

    static func addFriendRequest(senderId: String, targetId: String, requestDate: String) async -> Result<Bool, Error> {
        do {
            let friendRequestData = FriendRequestData(senderId: senderId, targetId: targetId, requestDate: requestDate, isComplete: false)
            let result = try await FirebaseService.shared.post(data: friendRequestData, collection: "friend_requests").get()
            
            // Update friend request to include request id
            _ = try await FirebaseService.shared.put(updates: ["request_id": result], docId: result, collection: "friend_requests").get()
            
            return .success(true)
        } catch {
            return .failure(error)
        }
    }

    static func getFriends(userId: String) async -> Result<[UserData], Error> {
        do {
            let result = try await FirebaseService.shared.get(type: UserData(), docId: userId, collection: "users").get()
            
            // Successful. Continue by iterating through all the friends
            guard let friendsMap = result.friends else {
                return .failure(FirebaseError.nullProperty)
            }
            
            let friendIds = Array(friendsMap.keys)

            let friendData: [UserData] = try await withThrowingTaskGroup(of: UserData.self) { group in
                for friend in friendIds {
                    group.addTask {
                        do {
                            return try await FirebaseService.shared.get(type: UserData(), docId: friend, collection: "users").get()
                        } catch {
                            throw error
                        }
                    }
                }
                
                var resultArr: [UserData] = []
                
                for try await result in group {
                    resultArr.append(result)
                }
                
                return resultArr
            }
            
            return .success(friendData)
        } catch {
            return .failure(error)
        }
    }
    
    static func updateFriendRequest(friendRequestId: String, isAccepted: Bool) async -> Result<Bool, Error> {
        do {
            let updates: [String: Any] = ["is_complete": true]
            
            if (isAccepted) {
                let friendRequestData = try await FirebaseService.shared.get(type: FriendRequestData(), docId: friendRequestId, collection: "friend_requests").get()
                if (friendRequestData.senderId == nil || friendRequestData.targetId == nil) {
                    return .failure(FirebaseError.nullProperty)
                }
                
                // Sender Id and Target Id are not nil, continue
                _ = await withThrowingTaskGroup(of: Bool.self) { group in
                    // Update senderId's friends map
                    group.addTask {
                        do {
                            let update = ["friends.\(friendRequestData.targetId!)": true]
                            return try await FirebaseService.shared.put(updates: update, docId: friendRequestData.senderId!, collection: "users").get()
                        } catch {
                            throw error
                        }
                    }
                    
                    // Update targetId's friends map
                    group.addTask {
                        do {
                            let update = ["friends.\(friendRequestData.senderId!)": true]
                            return try await FirebaseService.shared.put(updates: update, docId: friendRequestData.targetId!, collection: "users").get()
                        } catch {
                            throw error
                        }
                    }
                    
                    
                    return group
                }
                
            }
            
            let result = try await FirebaseService.shared.put(updates: updates, docId: friendRequestId, collection: "friend_requests").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func updateLogRequest(logRequestId: String, isAccepted: Bool) async -> Result<Bool, Error> {
        do {
            let updates: [String: Any] = ["is_complete": true]
            
            if (isAccepted) {
                let logRequestData = try await FirebaseService.shared.get(type: LogRequestData(), docId: logRequestId, collection: "log_requests").get()
                if (logRequestData.logId == nil || logRequestData.targetId == nil) {
                    return .failure(FirebaseError.nullProperty)
                }
                
                // Add collaborator
                let newCollaborator = ["collaborators.\(logRequestData.targetId!)": true]
                _ = try await FirebaseService.shared.put(updates: newCollaborator, docId: logRequestData.logId!, collection: "logs").get()
            }
            
            let result = try await FirebaseService.shared.put(updates: updates, docId: logRequestId, collection: "log_requests").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func removeFriend(userId: String, friendId: String) async -> Result<Bool, Error> {
        do {
            let result = try await withThrowingTaskGroup(of: Bool.self) { group in
                // Update userId's friends map
                group.addTask {
                    let updateUser = ["friends.\(friendId)": FieldValue.delete()]
                    do {
                        return try await FirebaseService.shared.put(updates: updateUser, docId: userId, collection: "users").get()
                    } catch {
                        throw error
                    }
                }
                    
                // Update friendId's friends map
                group.addTask {
                    let updateFriend = ["friends.\(userId)": FieldValue.delete()]
                    do {
                        return try await FirebaseService.shared.put(updates: updateFriend, docId: userId, collection: "users").get()
                    } catch {
                        throw error
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
    
    // TODO Ensure blocker is removed from friends list, logs involving this user (excluding one he owns)
    // Blocked user must also be removed from the logs that the user above owns
    static func blockUser(userId: String, blockedId: String) async -> Result<Bool, Error> {
        do {
            let updates = ["blocked.\(blockedId)": true]
            let result = try await FirebaseService.shared.put(updates: updates, docId: userId, collection: "users").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
