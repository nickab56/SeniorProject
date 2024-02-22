//
//  FriendRepository.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import FirebaseFirestore
import Foundation

class FriendRepository {
    let fb: FirebaseProtocol
    
    init(fb: FirebaseProtocol) {
        self.fb = fb
    }
    
    func addLogRequest(senderId: String, targetId: String, logId: String, requestDate: String) async -> Result<Bool, Error> {
        do {
            let logRequestData = LogRequestData(senderId: senderId, targetId: targetId, logId: logId, requestDate: requestDate, isComplete: false)
            let result = try await fb.post(data: logRequestData, collection: "log_requests").get()
            
            // Update log request to include request id
            _ = try await fb.put(updates: ["request_id": result], docId: result, collection: "log_requests").get()
            
            return .success(true)
        } catch {
            return .failure(error)
        }
    }

    func addFriendRequest(senderId: String, targetId: String, requestDate: String) async -> Result<Bool, Error> {
        do {
            let friendRequestData = FriendRequestData(senderId: senderId, targetId: targetId, requestDate: requestDate, isComplete: false)
            let result = try await fb.post(data: friendRequestData, collection: "friend_requests").get()
            
            // Update friend request to include request id
            _ = try await fb.put(updates: ["request_id": result], docId: result, collection: "friend_requests").get()
            
            return .success(true)
        } catch {
            return .failure(error)
        }
    }

    func getFriends(userId: String) async -> Result<[UserData], Error> {
        do {
            let result = try await fb.get(type: UserData(), docId: userId, collection: "users").get()
            
            // Successful. Continue by iterating through all the friends
            let friendIds = Array((result.friends ?? [:]).keys)

            let friendData: [UserData] = try await withThrowingTaskGroup(of: UserData.self) { group in
                for friend in friendIds {
                    group.addTask {
                        do {
                            return try await self.fb.get(type: UserData(), docId: friend, collection: "users").get()
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
    
    func updateFriendRequest(friendRequestId: String, isAccepted: Bool) async -> Result<Bool, Error> {
        do {
            let updates: [String: Any] = ["is_complete": true]
            
            if (isAccepted) {
                let friendRequestData = try await fb.get(type: FriendRequestData(), docId: friendRequestId, collection: "friend_requests").get()
                if (friendRequestData.senderId == nil || friendRequestData.targetId == nil) {
                    return .failure(FirebaseError.nullProperty)
                }
                
                // Sender Id and Target Id are not nil, continue
                
                // Update user's document first
                guard let userId = fb.getUserId() else {
                    return .failure(FirebaseError.nullProperty)
                }
                
                if (userId == friendRequestData.targetId!) {
                    // Update current user's document
                    var update = ["friends.\(friendRequestData.senderId!)": true]
                    _ = try await fb.put(updates: update, docId: friendRequestData.targetId!, collection: "users").get()
                    
                    // Update other user's document
                    update = ["friends.\(friendRequestData.targetId!)": true]
                    _ = try await fb.put(updates: update, docId: friendRequestData.senderId!, collection: "users").get()
                } else {
                    // Update current user's document
                    var update = ["friends.\(friendRequestData.targetId!)": true]
                    _ = try await fb.put(updates: update, docId: friendRequestData.senderId!, collection: "users").get()
                    
                    // Update other user's document
                    update = ["friends.\(friendRequestData.senderId!)": true]
                    _ = try await fb.put(updates: update, docId: friendRequestData.targetId!, collection: "users").get()
                }
            }
            
            let result = try await fb.put(updates: updates, docId: friendRequestId, collection: "friend_requests").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func updateLogRequest(logRequestId: String, isAccepted: Bool) async -> Result<Bool, Error> {
        do {
            let updates: [String: Any] = ["is_complete": true]
            
            if (isAccepted) {
                let logRequestData = try await fb.get(type: LogRequestData(), docId: logRequestId, collection: "log_requests").get()
                if (logRequestData.logId == nil || logRequestData.targetId == nil) {
                    return .failure(FirebaseError.nullProperty)
                }
                
                // Add collaborator
                let newCollaborator = ["collaborators.\(logRequestData.targetId!)": true]
                _ = try await fb.put(updates: newCollaborator, docId: logRequestData.logId!, collection: "logs").get()
            }
            
            let result = try await fb.put(updates: updates, docId: logRequestId, collection: "log_requests").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func removeFriend(userId: String, friendId: String) async -> Result<Bool, Error> {
        do {
            let result = try await withThrowingTaskGroup(of: Bool.self) { group in
                // Update userId's friends map
                group.addTask {
                    let updateUser = ["friends.\(friendId)": FieldValue.delete()]
                    do {
                        return try await self.fb.put(updates: updateUser, docId: userId, collection: "users").get()
                    } catch {
                        print("Error updating userId: \(error)")
                        throw error
                    }
                }
                    
                // Update friendId's friends map
                group.addTask {
                    let updateFriend = ["friends.\(userId)": FieldValue.delete()]
                    do {
                        return try await self.fb.put(updates: updateFriend, docId: friendId, collection: "users").get()
                    } catch {
                        print("Error updating friendId: \(error)")
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
    
    // TODO Ensure blocker is removed from logs involving this user (excluding one he owns)
    // Blocked user must also be removed from the logs that the user above owns
    func blockUser(userId: String, blockedId: String) async -> Result<Bool, Error> {
        do {
            // Add to blocked
            let updates = ["blocked.\(blockedId)": true]
            let result = try await fb.put(updates: updates, docId: userId, collection: "users").get()
            
            // Remove from friends list (both)
            _ = try await removeFriend(userId: userId, friendId: blockedId).get()
            _ = try await removeFriend(userId: blockedId, friendId: userId).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
