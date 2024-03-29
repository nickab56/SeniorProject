//
//  FriendRepositoryTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class FriendRepositoryTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var friendRepoSucceed: FriendRepository!
    
    var mockFBError: MockFirebaseService!
    var friendRepoError: FriendRepository!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        friendRepoSucceed = FriendRepository(fb: mockFBSucceed)
        
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        friendRepoError = FriendRepository(fb: mockFBError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        friendRepoSucceed = nil
        mockFBError = nil
        friendRepoError = nil
        super.tearDown()
    }
    
    func testAddLogRequestSuccess() async {
        let reqData = LogRequestData(requestId: "req123", senderId: "sender123", targetId: "target456", logId: "log123", requestDate: "now", isComplete: false)
        
        do {
            let result = try await friendRepoSucceed.addLogRequest(
                senderId: reqData.requestId!,
                targetId: reqData.targetId!,
                logId: reqData.logId!,
                requestDate: reqData.requestDate!
            ).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testAddLogRequestThrowsError() async {
        let reqData = LogRequestData(requestId: "req123", senderId: "sender123", targetId: "target456", logId: "log123", requestDate: "now", isComplete: false)
        
        do {
            _ = try await friendRepoError.addLogRequest(
                senderId: reqData.requestId!,
                targetId: reqData.targetId!,
                logId: reqData.logId!,
                requestDate: reqData.requestDate!
            ).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testAddFriendRequestSuccess() async {
        let reqData = FriendRequestData(requestId: "req123", senderId: "sender123", targetId: "target456", requestDate: "now", isComplete: false)
        
        do {
            let result = try await friendRepoSucceed.addFriendRequest(
                senderId: reqData.requestId!,
                targetId: reqData.targetId!,
                requestDate: reqData.requestDate!
            ).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testAddFriendRequestThrowsError() async {
        let reqData = FriendRequestData(requestId: "req123", senderId: "sender123", targetId: "target456", requestDate: "now", isComplete: false)
        
        do {
            _ = try await friendRepoError.addFriendRequest(
                senderId: reqData.requestId!,
                targetId: reqData.targetId!,
                requestDate: reqData.requestDate!
            ).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testGetFriendsSuccess() async {
        let userData = UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:])
        
        do {
            let result = try await friendRepoSucceed.getFriends(userId: userData.userId!).get()
            
            XCTAssert(result.count == userData.friends?.count)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetFriendsThrowsError() async {
        let userData = UserData(userId: "mockUserId", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:])
        
        do {
            _ = try await friendRepoError.getFriends(userId: userData.userId!).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUpdateFriendRequestAcceptedSuccess() async {
        let reqId = "req123"
        
        do {
            let result = try await friendRepoSucceed.updateFriendRequest(friendRequestId: reqId, isAccepted: true).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateFriendRequestAcceptedThrowsError() async {
        let reqId = "req123"
        
        do {
            _ = try await friendRepoError.updateFriendRequest(friendRequestId: reqId, isAccepted: true).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUpdateFriendRequestRejectedSuccess() async {
        let reqId = "req123"
        
        do {
            let result = try await friendRepoSucceed.updateFriendRequest(friendRequestId: reqId, isAccepted: false).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateFriendRequestRejectedThrowsError() async {
        let reqId = "req123"
        
        do {
            _ = try await friendRepoError.updateFriendRequest(friendRequestId: reqId, isAccepted: false).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUpdateLogRequestAcceptedSuccess() async {
        let reqId = "req123"
        
        do {
            let result = try await friendRepoSucceed.updateLogRequest(logRequestId: reqId, isAccepted: true).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateLogRequestAcceptedThrowsError() async {
        let reqId = "req123"
        
        do {
            _ = try await friendRepoError.updateLogRequest(logRequestId: reqId, isAccepted: true).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testUpdateLogRequestRejectedSuccess() async {
        let reqId = "req123"
        
        do {
            let result = try await friendRepoSucceed.updateLogRequest(logRequestId: reqId, isAccepted: false).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testUpdateLogRequestRejectedThrowsError() async {
        let reqId = "req123"
        
        do {
            _ = try await friendRepoError.updateLogRequest(logRequestId: reqId, isAccepted: false).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testRemoveFriendSuccess() async {
        let userId = "mockUserId"
        let removedId = "removedUserId"
        
        do {
            let result = try await friendRepoSucceed.removeFriend(userId: userId, friendId: removedId).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testRemoveFriendThrowsError() async {
        let userId = "mockUserId"
        let removedId = "removedUserId"
        
        do {
            _ = try await friendRepoError.removeFriend(userId: userId, friendId: removedId).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testBlockUserSuccess() async {
        let userId = "mockUserId"
        let blockedId = "blockedUserId"
        
        do {
            let result = try await friendRepoSucceed.blockUser(userId: userId, blockedId: blockedId).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testBlockUserThrowsError() async {
        let userId = "mockUserId"
        let blockedId = "blockedUserId"
        
        do {
            _ = try await friendRepoError.blockUser(userId: userId, blockedId: blockedId).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
}

