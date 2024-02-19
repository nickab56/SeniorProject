//
//  UserDataTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class UserDataTests: XCTestCase {

    func testEquality() {
        let data1 = UserData(userId: "1", username: "User1", joinDate: "2024-01-21", avatarPreset: 1, friends: ["friend1": true], blocked: ["blocked1": true])
        let data2 = UserData(userId: "1", username: "User1", joinDate: "2024-01-21", avatarPreset: 1, friends: ["friend1": true], blocked: ["blocked1": true])
        
        XCTAssertEqual(data1, data2)
    }
    
    func testIdentifiable() {
        let data = UserData(userId: "1", username: "User1", joinDate: "2024-01-21", avatarPreset: 1, friends: ["friend1": true], blocked: ["blocked1": true])
        
        XCTAssertEqual(data.userId, data.id)
    }
    
    func testNilIdentifiable() {
        let data = UserData(userId: nil, username: "User1", joinDate: "2024-01-21", avatarPreset: 1, friends: ["friend1": true], blocked: ["blocked1": true])
        
        XCTAssertEqual(data.id, "")
    }
    
    func testCodable() {
        let data = UserData(userId: "1", username: "User1", joinDate: "2024-01-21", avatarPreset: 1, friends: ["friend1": true], blocked: ["blocked1": true])
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            let decodedData = try JSONDecoder().decode(UserData.self, from: jsonData)
            XCTAssertEqual(data, decodedData)
        } catch {
            XCTFail("Failed to encode or decode UserData: \(error)")
        }
    }
}
