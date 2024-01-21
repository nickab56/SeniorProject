//
//  LogData.swift
//  backblog
//
//  Created by Jake Buhite on 1/21/24.
//

import Foundation

class LogData: Codable, Equatable {
    static func == (lhs: LogData, rhs: LogData) -> Bool {
        return lhs.logID == rhs.logID
    }
    
    var logID: String?
    var name: String?
    var isVisible: Bool?
    var movieIds: Dictionary<String, Bool>?
    var watchedIds: Dictionary<String, Bool>?
    var collaborators: Dictionary<String, Dictionary<String, Int>>
    var creationDate: String?
    var lastModifiedDate: String?
}

extension LogData {
    class Owner: Codable {
        var userId: String?
        var priority: Int?
    }
}
