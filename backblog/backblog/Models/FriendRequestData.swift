//
//  FriendRequestData.swift
//  backblog
//
//  Created by Jake Buhite on 1/21/24.
//

import Foundation

class FriendRequestData: Codable, Equatable {
    static func == (lhs: FriendRequestData, rhs: FriendRequestData) -> Bool {
        return lhs.targetId == rhs.targetId && lhs.senderId == rhs.senderId && lhs.requestDate == rhs.requestDate && lhs.isComplete == rhs.isComplete
    }
    
    var senderId: String?
    var targetId: String?
    var requestDate: String?
    var isComplete: Bool?
    
    enum CodingKeys: String, CodingKey {
        case senderId = "sender_id"
        case targetId = "target_id"
        case requestDate = "request_date"
        case isComplete = "is_complete"
    }
}


