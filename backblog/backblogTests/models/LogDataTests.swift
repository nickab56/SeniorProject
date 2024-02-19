//
//  LogDataTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class LogDataTests: XCTestCase {

    func testEquality() {
        let data1 = LogData(logId: "1", name: "Log 1", creationDate: "before", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "user1", priority: 1), movieIds: ["movie1"], watchedIds: ["watched1"], collaborators: ["collab1"], order: ["key": 1])
        let data2 = LogData(logId: "1", name: "Log 1", creationDate: "before", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "user1", priority: 1), movieIds: ["movie1"], watchedIds: ["watched1"], collaborators: ["collab1"], order: ["key": 1])
        
        XCTAssertEqual(data1, data2)
    }
    
    func testIdentifiable() {
        let data = LogData(logId: "1", name: "Log 1", creationDate: "before", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "user1", priority: 1), movieIds: ["movie1"], watchedIds: ["watched1"], collaborators: ["collab1"], order: ["key": 1])
        
        XCTAssertEqual(data.logId, data.id)
    }
    
    func testNilIdentifiable() {
        let data = LogData(logId: nil, name: "Log 1", creationDate: "before", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "user1", priority: 1), movieIds: ["movie1"], watchedIds: ["watched1"], collaborators: ["collab1"], order: ["key": 1])
        
        XCTAssertEqual(data.id, "")
    }
    
    func testCodable() {
        let data = LogData(logId: "1", name: "Log 1", creationDate: "before", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "user1", priority: 1), movieIds: ["movie1"], watchedIds: ["watched1"], collaborators: ["collab1"], order: ["key": 1])
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            let decodedData = try JSONDecoder().decode(LogData.self, from: jsonData)
            XCTAssertEqual(data, decodedData)
        } catch {
            XCTFail("Failed to encode or decode LogData: \(error)")
        }
    }
}
