//
//  UserData.swift
//  backblog
//
//  Created by Jake Buhite on 1/21/24.
//  Updated by Jake Buhite on 2/23/24.
//

import Foundation

/// Represents the data model for UserData from Firebase.
struct UserData: Identifiable, Codable, Equatable, Hashable {
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.userId == rhs.userId && lhs.username == rhs.username &&
        lhs.avatarPreset == rhs.avatarPreset
    }
    
    var id: String {
        return userId ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
    var userId: String?
    var username : String?
    var joinDate: String?
    var avatarPreset: Int?
    var friends: Dictionary<String, Bool>?
    var blocked: Dictionary<String, Bool>?
    
    enum CodingKeys: String, CodingKey {
        case username, friends, blocked
        case userId = "user_id"
        case joinDate = "join_date"
        case avatarPreset = "avatar_preset"
    }
}
