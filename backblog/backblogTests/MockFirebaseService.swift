//
//  MockFirebaseService.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/12/24.
//

import Firebase
import FirebaseFirestoreSwift
@testable import backblog

class MockFirebaseService: FirebaseProtocol {
    var shouldSucceed = true // Flag to control success/failure of methods
    
    // Friends Repo testing
    var isTargetId = true
    var senderIdNil = false
    var targetIdNil = false
    
    // TODO: Support all types for BackBlog
    func get<T>(type: T, query: Query?) async -> Result<T, Error> where T : Decodable {
        if shouldSucceed {
            let userData = UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:]) as! T
            return .success(userData)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func get<T>(type: T, docId: String, collection: String) async -> Result<T, Error> where T : Decodable {
        if shouldSucceed {
            switch (T.self) {
            case is UserData.Type:
                return .success(UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:]) as! T)
            default:
                let senderId: String? = if (senderIdNil) { nil } else { "senderId" }
                let targetId: String? = if (targetIdNil) { nil } else { "mockUserId" }
                return .success(FriendRequestData(requestId: "req123", senderId: senderId, targetId: targetId, requestDate: "now", isComplete: false) as! T)
            }
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func getBatch<T>(type: T, query: Query?) async -> Result<[T], Error> where T : Decodable {
        if shouldSucceed {
            switch (T.self) {
            case is UserData.Type:
                return .success([UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: [:], blocked: [:]) as! T,
                        UserData(userId: "mockUserId2", username: "mockUsername2", joinDate: "future", avatarPreset: 2, friends: [:], blocked: [:]) as! T])
            case is LogRequestData.Type:
                return .success([LogRequestData(requestId: "req123", senderId: "sender123", targetId: "target456", logId: "log123", requestDate: "now", isComplete: false) as! T,
                                 LogRequestData(requestId: "req456", senderId: "sender456", targetId: "target456", logId: "log456", requestDate: "old", isComplete: true) as! T])
            case is FriendRequestData.Type:
                return .success([FriendRequestData(requestId: "req123", senderId: "sender123", targetId: "target456", requestDate: "now", isComplete: false) as! T,
                                 FriendRequestData(requestId: "req456", senderId: "bob123", targetId: "target456", requestDate: "old", isComplete: true) as! T])
            default:
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid type"])
                return .failure(error)
            }
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func put<T>(doc: T, docId: String, collection: String) async -> Result<T, Error> where T : Codable {
        if shouldSucceed {
            return .success(doc)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    // Complete
    func exists(query: Query?) async -> Result<Bool, Error> {
        if shouldSucceed {
            return .success(true)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func post<T>(data: T, collection: String) async -> Result<String, Error> where T : Codable {
        if shouldSucceed {
            return .success("MockDocumentID")
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func put(updates: [String : Any], docId: String, collection: String) async -> Result<Bool, Error> {
        if shouldSucceed {
            return .success(true)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func delete<T>(doc: T, docId: String, collection: String) async -> Result<Bool, Error> where T : Codable {
        if shouldSucceed {
            return .success(true)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func register(email: String, password: String) async -> Result<String, Error> {
        if shouldSucceed {
            return .success("MockUserID")
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func login(email: String, password: String) async -> Result<Bool, Error> {
        if shouldSucceed {
            return .success(true)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func updatePassword(password: String, newPassword: String) async -> Result<Bool, Error> {
        if shouldSucceed {
            return .success(true)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func logout() -> Result<Bool, Error> {
        if shouldSucceed {
            return .success(true)
        } else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            return .failure(error)
        }
    }
    
    func getUserId() -> String? {
        if shouldSucceed {
            if isTargetId {
               return "mockUserId"
            }
            return "targetUserId"
        } else {
            return nil
        }
    }
    
    func getCollectionRef(refName: String) -> CollectionReference? {
        return nil
    }
}
