//
//  UserRepository.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import Foundation

class UserRepository {
    static func addUser(userId: String, username: String, avatarPreset: Int) async -> Result<UserData, Error> {
        do {
            let userData = UserData(
                userId: userId,
                username: username,
                joinDate: String(currentTimeInMS()),
                avatarPreset: avatarPreset,
                friends: [:],
                blocked: [:]
            )
            
            let result = try await FirebaseService.shared.put(doc: userData, docId: userId, collection: "users").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func getUser(userId: String) async -> Result<UserData, Error> {
        do {
            let result = try await FirebaseService.shared.get(type: UserData(), docId: userId, collection: "users").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func updateUser(userId: String, updateData: [String: Any]) async -> Result<Bool, Error> {
        do {
            var newData = updateData
            var password: String?
            
            // Remove password from update
            if updateData["password"] != nil {
                password = updateData["password"] as? String
                newData.removeValue(forKey: "password")
            }
            
            let result = try await FirebaseService.shared.put(updates: newData, docId: userId, collection: "users").get()
            
            if password != nil {
                // TODO: Update password if provided through firebase auth
            }
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func getLogRequests(userId: String) async -> Result<[LogRequestData], Error> {
        do {
            let q = FirebaseService.shared.db.collection("log_requests").whereField("target_id", isEqualTo: userId)
            let result = try await FirebaseService.shared.getBatch(type: LogRequestData(), query: q).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func getFriendRequests(userId: String) async -> Result<[FriendRequestData], Error> {
        do {
            let q = FirebaseService.shared.db.collection("friend_requests").whereField("target_id", isEqualTo: userId)
            let result = try await FirebaseService.shared.getBatch(type: FriendRequestData(), query: q).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    
}
