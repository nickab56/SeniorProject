//
//  UserRepositoryTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class UserRepositoryTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var userRepoSucceed: UserRepository!
    
    var mockFBError: MockFirebaseService!
    var userRepoError: UserRepository!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        userRepoSucceed = UserRepository(fb: mockFBSucceed)
        
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        userRepoError = UserRepository(fb: mockFBError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        userRepoSucceed = nil
        mockFBError = nil
        userRepoError = nil
        super.tearDown()
    }
    
    func testAddUserSuccess() async {
        let userId = "mockUserId"
        let username = "mockUsername"
        
        do {
            let result = try await userRepoSucceed.addUser(userId: userId, username: username, avatarPreset: 1).get()
            
            XCTAssertEqual(result.userId, userId)
            XCTAssertEqual(result.username, username)
            XCTAssertEqual(result.avatarPreset, 1)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testAddUserThrowsError() async {
        let userId = "mockUserId"
        let username = "mockUsername"
        
        do {
            _ = try await userRepoError.addUser(userId: userId, username: username, avatarPreset: 1).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testGetUserSuccess() async {
        let userData = UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:])
        
        do {
            let result = try await userRepoSucceed.getUser(userId: userData.userId ?? "").get()
            
            XCTAssertEqual(result.userId, userData.userId)
            XCTAssertEqual(result.username, userData.username)
            XCTAssertEqual(result.joinDate, userData.joinDate)
            XCTAssertEqual(result.avatarPreset, userData.avatarPreset)
            XCTAssertEqual(result.friends, userData.friends)
            XCTAssertEqual(result.blocked, userData.blocked)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetUserThrowsError() async {
        let userData = UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: [:], blocked: [:])
        
        do {
            _ = try await userRepoError.getUser(userId: userData.userId ?? "").get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testGetUserByUsernameSuccess() async {
        let userData = UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:])
        
        do {
            let result = try await userRepoSucceed.getUserByUsername(username: userData.username ?? "").get()
            
            XCTAssertEqual(result.userId, userData.userId)
            XCTAssertEqual(result.username, userData.username)
            XCTAssertEqual(result.joinDate, userData.joinDate)
            XCTAssertEqual(result.avatarPreset, userData.avatarPreset)
            XCTAssertEqual(result.friends, userData.friends)
            XCTAssertEqual(result.blocked, userData.blocked)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetUserByUsernameThrowsError() async {
        let userData = UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: [:], blocked: [:])
        
        do {
            _ = try await userRepoError.getUserByUsername(username: userData.username ?? "").get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUsernameExistsSuccess() async {
        let username = "mockUsername"
        
        do {
            let result = try await userRepoSucceed.usernameExists(username: username).get()
            
            XCTAssertTrue(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUsernameExistsThrowsError() async {
        let username = "mockUsername"
        
        do {
            _ = try await userRepoError.usernameExists(username: username).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUpdateUserSuccess() async {
        let userId = "mockUserId"
        let password = "oldPassword"
        let updateData = ["username": "mockUsername2"]
        
        do {
            let result = try await userRepoSucceed.updateUser(userId: userId, password: password, updateData: updateData).get()
            
            XCTAssertTrue(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateUserThrowsError() async {
        let userId = "mockUserId"
        let password = "oldPassword"
        let updateData = ["username": "mockUsername2"]
        
        do {
            _ = try await userRepoError.updateUser(userId: userId, password: password, updateData: updateData).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUpdateUserNewPasswordNotNilSuccess() async {
        let userId = "mockUserId"
        let password = "oldPassword"
        let updateData = ["username": "mockUsername2", "password": "newPassword"]
        
        do {
            let result = try await userRepoSucceed.updateUser(userId: userId, password: password, updateData: updateData).get()
            XCTAssertTrue(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateUserNewPasswordNotNilThrowsError() async {
        let userId = "mockUserId"
        let password = "oldPassword"
        let updateData = ["username": "mockUsername2", "password": "newPassword"]
        
        do {
            _ = try await userRepoError.updateUser(userId: userId, password: password, updateData: updateData).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testGetLogRequestsSuccess() async {
        let userId = "mockUserId"
        let logReq = LogRequestData(requestId: "req123", senderId: "sender123", targetId: "target456", logId: "log123", requestDate: "now", isComplete: false)
        
        do {
            let result = try await userRepoSucceed.getLogRequests(userId: userId).get()
            
            XCTAssert(!result.isEmpty)
            
            XCTAssertEqual(result[0].requestId, logReq.requestId)
            XCTAssertEqual(result[0].senderId, logReq.senderId)
            XCTAssertEqual(result[0].targetId, logReq.targetId)
            XCTAssertEqual(result[0].logId, logReq.logId)
            XCTAssertEqual(result[0].requestDate, logReq.requestDate)
            XCTAssertEqual(result[0].isComplete, logReq.isComplete)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetLogRequestsThrowsError() async {
        let userId = "mockUserId"
        
        do {
            _ = try await userRepoError.getLogRequests(userId: userId).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testGetFriendRequestsSuccess() async {
        let userId = "mockUserId"
        let logReq = FriendRequestData(requestId: "req123", senderId: "sender123", targetId: "target456", requestDate: "now", isComplete: false)
        
        do {
            let result = try await userRepoSucceed.getFriendRequests(userId: userId).get()
            
            XCTAssert(!result.isEmpty)
            
            XCTAssertEqual(result[0].requestId, logReq.requestId)
            XCTAssertEqual(result[0].senderId, logReq.senderId)
            XCTAssertEqual(result[0].targetId, logReq.targetId)
            XCTAssertEqual(result[0].requestDate, logReq.requestDate)
            XCTAssertEqual(result[0].isComplete, logReq.isComplete)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetFriendRequestsThrowsError() async {
        let userId = "mockUserId"
        
        do {
            _ = try await userRepoError.getFriendRequests(userId: userId).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
}
