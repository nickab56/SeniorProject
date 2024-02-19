//
//  FriendRequestDataTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class FriendRequestDataTests: XCTestCase {

    func testEquality() {
        let data1 = FriendRequestData(requestId: "1", senderId: "sender1", targetId: "target1", requestDate: "now", isComplete: true)
        let data2 = FriendRequestData(requestId: "1", senderId: "sender1", targetId: "target1", requestDate: "now", isComplete: true)
        
        XCTAssertEqual(data1, data2)
    }
    
    func testHashable() {
        let data = FriendRequestData(requestId: "1", senderId: "sender1", targetId: "target1", requestDate: "now", isComplete: true)
        
        var hasher = Hasher()
        data.hash(into: &hasher)
        let hashedValue = hasher.finalize()
        XCTAssertNotNil(hashedValue)
    }
    
    func testCodingKeys() {
        XCTAssertEqual(FriendRequestData.CodingKeys.requestId.rawValue, "request_id")
        XCTAssertEqual(FriendRequestData.CodingKeys.senderId.rawValue, "sender_id")
        XCTAssertEqual(FriendRequestData.CodingKeys.targetId.rawValue, "target_id")
        XCTAssertEqual(FriendRequestData.CodingKeys.requestDate.rawValue, "request_date")
        XCTAssertEqual(FriendRequestData.CodingKeys.isComplete.rawValue, "is_complete")
    }
}
