//
//  UserData.swift
//  backblog
//
//  Created by Jake Buhite on 1/21/24.
//

import Foundation

class UserData: Codable, Equatable {
    static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    var userId: String?
    var username : String?
    var joinDate: String?
    var avatarPreset: Int?
    var friends: Dictionary<String, Bool>?
    var blocked: Dictionary<String, Bool>?
    
    enum CodingKeys: String, CodingKey {
        case userId = "log_id"
        case username
        case joinDate = "join_date"
        case avatarPreset = "avatar_preset"
        case friends
        case blocked
    }
}
