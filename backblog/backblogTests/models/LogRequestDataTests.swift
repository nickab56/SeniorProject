//
//  LogRequestDataTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class LogRequestDataTests: XCTestCase {

    func testEquality() {
        let data1 = LogRequestData(requestId: "1", senderId: "sender1", targetId: "target1", logId: "log1", requestDate: "now", isComplete: true)
        let data2 = LogRequestData(requestId: "1", senderId: "sender1", targetId: "target1", logId: "log1", requestDate: "now", isComplete: true)
        
        XCTAssertEqual(data1, data2)
    }
    
    func testHashable() {
        let data = LogRequestData(requestId: "1", senderId: "sender1", targetId: "target1", logId: "log1", requestDate: "now", isComplete: true)
        
        var hasher = Hasher()
        data.hash(into: &hasher)
        let hashedValue = hasher.finalize()
        XCTAssertNotNil(hashedValue)
    }
    
    func testCodable() {
        let data = LogRequestData(requestId: "1", senderId: "sender1", targetId: "target1", logId: "log1", requestDate: "now", isComplete: true)
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            let decodedData = try JSONDecoder().decode(LogRequestData.self, from: jsonData)
            XCTAssertEqual(data, decodedData)
        } catch {
            XCTFail("Failed to code LogRequestData: \(error)")
        }
    }
}
