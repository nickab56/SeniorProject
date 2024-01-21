//
//  LogRequestData.swift
//  backblog
//
//  Created by Jake Buhite on 1/21/24.
//

import Foundation

class LogRequestData: Codable, Equatable {
    static func == (lhs: LogRequestData, rhs: LogRequestData) -> Bool {
        return lhs.targetId == rhs.targetId && lhs.senderId == rhs.senderId && lhs.requestDate == rhs.requestDate && lhs.isComplete == rhs.isComplete && lhs.logId == rhs.logId
    }
    
    var senderId: String?
    var targetId: String?
    var logId: String?
    var requestDate: String?
    var isComplete: Bool?
}
