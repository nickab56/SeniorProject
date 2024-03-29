//
//  LogRequestData.swift
//  backblog
//
//  Created by Jake Buhite on 1/21/24.
//  Updated by Jake Buhite on 2/23/24.
//

import Foundation

/// Represents the data model for LogRequestData from Firebase.
struct LogRequestData: Hashable, Codable, Equatable {
    static func == (lhs: LogRequestData, rhs: LogRequestData) -> Bool {
        return lhs.targetId == rhs.targetId && lhs.senderId == rhs.senderId && lhs.requestDate == rhs.requestDate && lhs.isComplete == rhs.isComplete && lhs.logId == rhs.logId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(senderId)
        hasher.combine(targetId)
        hasher.combine(logId)
    }
    
    var requestId: String?
    var senderId: String?
    var targetId: String?
    var logId: String?
    var requestDate: String?
    var isComplete: Bool?
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case senderId = "sender_id"
        case targetId = "target_id"
        case logId = "log_id"
        case requestDate = "request_date"
        case isComplete = "is_complete"
    }
    
}
