//
//  LogData.swift
//  backblog
//
//  Created by Jake Buhite on 1/21/24.
//

import Foundation

class LogData: Codable, Equatable {
    static func == (lhs: LogData, rhs: LogData) -> Bool {
        return lhs.logId == rhs.logId
    }
    
    var logId: String?
    var name: String?
    var creationDate: String?
    var lastModifiedDate: String?
    var isVisible: Bool?
    var owner: Owner?
    var movieIds: Dictionary<String, Bool>?
    var watchedIds: Dictionary<String, Bool>?
    var collaborators: Dictionary<String, Dictionary<String, Int>>
    
    class Owner: Codable {
        var userId: String?
        var priority: Int?
        
        private enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case priority
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case logId = "log_id"
        case name
        case creationDate = "creation_date"
        case lastModifiedDate = "last_modified_date"
        case isVisible = "is_visible"
        case movieIds = "movie_ids"
        case watchedIds = "watched_ids"
        case collaborators
    }
}