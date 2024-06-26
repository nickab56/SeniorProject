//
//  UserRepository.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import Foundation

class UserRepository {
    let fb: FirebaseProtocol
    
    init(fb: FirebaseProtocol) {
        self.fb = fb
    }
    
    func addUser(userId: String, username: String, avatarPreset: Int) async -> Result<UserData, Error> {
        do {
            let userData = UserData(
                userId: userId,
                username: username,
                joinDate: String(currentTimeInMS()),
                avatarPreset: avatarPreset,
                friends: [:],
                blocked: [:]
            )
            
            let result = try await fb.put(doc: userData, docId: userId, collection: "users").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getUser(userId: String) async -> Result<UserData, Error> {
        do {
            let result = try await fb.get(type: UserData(), docId: userId, collection: "users").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getUserByUsername(username: String) async -> Result<UserData, Error> {
        do {
            let q = fb.getCollectionRef(refName: "users")?.whereField("username", isEqualTo: username)
            
            let result = try await fb.get(type: UserData(), query: q).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func usernameExists(username: String) async -> Result<Bool, Error> {
        do {
            let q = fb.getCollectionRef(refName: "users")?.whereField("username", isEqualTo: username)
            
            let result = try await fb.exists(query: q).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func updateUser(userId: String, password: String, updateData: [String: Any]) async -> Result<Bool, Error> {
        do {
            var newData = updateData
            var newPassword: String?
            
            // Remove password from update
            if updateData["password"] != nil {
                newPassword = updateData["password"] as? String
                newData.removeValue(forKey: "password")
            }
            
            let result = try await fb.put(updates: newData, docId: userId, collection: "users").get()
            
            if newPassword != nil {
                _ = try await fb.updatePassword(password: password, newPassword: newPassword!).get()
            }
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getLogRequests(userId: String) async -> Result<[LogRequestData], Error> {
        do {
            let q = fb.getCollectionRef(refName: "log_requests")?.whereField("target_id", isEqualTo: userId).whereField("is_complete", isEqualTo: false)
            let result = try await fb.getBatch(type: LogRequestData(), query: q).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getFriendRequests(userId: String) async -> Result<[FriendRequestData], Error> {
        do {
            let q = fb.getCollectionRef(refName: "friend_requests")?.whereField("target_id", isEqualTo: userId).whereField("is_complete", isEqualTo: false)
            let result = try await fb.getBatch(type: FriendRequestData(), query: q).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getLogRequests(userId: String, friendId: String) async -> Result<[LogRequestData], Error> {
        do {
            let q = fb.getCollectionRef(refName: "log_requests")?.whereField("target_id", isEqualTo: userId).whereField("sender_id", isEqualTo: friendId).whereField("is_complete", isEqualTo: false)
            var result = try await fb.getBatch(type: LogRequestData(), query: q).get()
            
            let q1 = fb.getCollectionRef(refName: "log_requests")?.whereField("target_id", isEqualTo: friendId).whereField("sender_id", isEqualTo: userId).whereField("is_complete", isEqualTo: false)
            let result1 = try await fb.getBatch(type: LogRequestData(), query: q1).get()
            
            result.append(contentsOf: result1)
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getFriendRequests(userId: String, friendId: String) async -> Result<[FriendRequestData], Error> {
        do {
            let q = fb.getCollectionRef(refName: "friend_requests")?.whereField("target_id", isEqualTo: userId).whereField("sender_id", isEqualTo: friendId).whereField("is_complete", isEqualTo: false)
            var result = try await fb.getBatch(type: FriendRequestData(), query: q).get()
            
            let q1 = fb.getCollectionRef(refName: "friend_requests")?.whereField("target_id", isEqualTo: friendId).whereField("sender_id", isEqualTo: userId).whereField("is_complete", isEqualTo: false)
            let result1 = try await fb.getBatch(type: FriendRequestData(), query: q1).get()
            
            result.append(contentsOf: result1)
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
}
