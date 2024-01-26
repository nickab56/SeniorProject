//
//  FriendRepository.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import FirebaseFirestore
import Foundation

class FriendRepository {
    static func addLogRequest(senderId: String, targetId: String, logId: String, requestDate: String) async -> Result<LogRequestData, Error> {
        do {
            let logRequestData = LogRequestData(senderId: senderId, targetId: targetId, logId: logId, requestDate: requestDate, isComplete: false)
            let result = try await FirebaseService.shared.post(data: logRequestData, collection: "log_requests").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    static func addFriendRequest(senderId: String, targetId: String, requestDate: String) async -> Result<FriendRequestData, Error> {
        do {
            let friendRequestData = FriendRequestData(senderId: senderId, targetId: targetId, requestDate: requestDate, isComplete: false)
            let result = try await FirebaseService.shared.post(data: friendRequestData, collection: "friend_requests").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    static func getFriends(userId: String) async -> Result<UserData, Error> {
        do {
            let q = FirebaseService.shared.db.collection("users").document(userId)
            let result = try await FirebaseService.shared.get(type: UserData(), docRef: q).get()
            
            // Successful. Continue by iterating through all the friends
            guard let friendsMap = result.friends else {
                return .failure(FirebaseError.nullProperty)
            }
            
            let friendIds = Array(friendsMap.keys)

            let friendData: [UserData] = try await withThrowingTaskGroup(of: UserData.self) { group in
                for friend in friendIds {
                    let q = FirebaseService.shared.db.collection("users").document(friend)
                    group.addTask {
                        do {
                            return try await FirebaseService.shared.get(type: UserData(), docRef: q).get()
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
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
