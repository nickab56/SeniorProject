//
//  FriendRequestData.swift
//  backblog
//
//  Created by Jake Buhite on 1/21/24.
//  Updated by Jake Buhite on 2/23/24.
//

import Foundation

/// Represents the data model for FriendRequestData from Firebase.
struct FriendRequestData: Hashable, Codable, Equatable {
    static func == (lhs: FriendRequestData, rhs: FriendRequestData) -> Bool {
        return lhs.targetId == rhs.targetId && lhs.senderId == rhs.senderId && lhs.requestDate == rhs.requestDate && lhs.isComplete == rhs.isComplete
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(senderId)
        hasher.combine(targetId)
    }
    
    var requestId: String?
    var senderId: String?
    var targetId: String?
    var requestDate: String?
    var isComplete: Bool?
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case senderId = "sender_id"
        case targetId = "target_id"
        case requestDate = "request_date"
        case isComplete = "is_complete"
    }
}


