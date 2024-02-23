//
//  LogType.swift
//  A simple generic enum for the LogType
//  backblog
//
//  Created by Jake Buhite on 2/8/24.
//

import Foundation

enum LogType: Identifiable {
    case localLog(LocalLogData)
    case log(LogData)
    
    var id: String {
        switch self {
        case .localLog(let log):
            return String(log.log_id)
        case .log(let log):
            return log.logId ?? ""
        }
    }
    
    func toLocalLog() -> LocalLogData? {
        switch self {
        case .localLog(let log):
            return log
        default:
            return nil
        }
    }
    
    func toLog() -> LogData? {
        switch self {
        case .log(let log):
            return log
        default:
            return nil
        }
    }
}
