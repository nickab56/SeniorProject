//
//  FriendsProfileViewModel.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/21/24.
//

import XCTest
@testable import backblog

class FriendsProfileViewModelTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var friendsProfileVMSucceed: FriendsProfileViewModel!
    
    var mockFBError: MockFirebaseService!
    var friendsProfileVMError: FriendsProfileViewModel!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false

        friendsProfileVMSucceed = FriendsProfileViewModel(friendId: "mockUserId", fb: mockFBSucceed)
        friendsProfileVMError = FriendsProfileViewModel(friendId: "mockUserId", fb: mockFBError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        friendsProfileVMSucceed = nil
        mockFBError = nil
        friendsProfileVMError = nil
        super.tearDown()
    }
    
    func testGetUserId() {
        let successResult = friendsProfileVMSucceed.getUserId()
        mockFBError.validUserId = false
        let errorResult = friendsProfileVMError.getUserId()
        
        XCTAssertEqual(successResult, "mockUserId")
        XCTAssertEqual(errorResult, "")
    }
    
    func testUserIsFriend() {
        friendsProfileVMSucceed.userData = UserData(userId: "mockUserId2", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["mockUserId":true], blocked: [:])
        let successResult = friendsProfileVMSucceed.userIsFriend()
        let errorResult = friendsProfileVMError.userIsFriend()
        
        XCTAssertEqual(successResult, true)
        XCTAssertEqual(errorResult, false)
    }
    
    func testRemoveFriendSuccess() {
        friendsProfileVMSucceed.removeFriend()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMSucceed.notificationMessage.contains("You are no longer friends with") &&
                self.friendsProfileVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testRemoveFriendInvalidUserId() {
        mockFBError.validUserId = false
        friendsProfileVMError.removeFriend()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMError.showingNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testRemoveFriendError() {
        friendsProfileVMError.removeFriend()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMError.notificationMessage.contains("There was an error unfriending") &&
                self.friendsProfileVMError.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testBlockUserSuccess() {
        friendsProfileVMSucceed.blockUser()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMSucceed.notificationMessage.contains("You have blocked") &&
                self.friendsProfileVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testBlockUserInvalidUserId() {
        mockFBError.validUserId = false
        friendsProfileVMError.blockUser()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMError.showingNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testBlockUserError() {
        friendsProfileVMError.blockUser()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMError.notificationMessage.contains("There was an error blocking") &&
                self.friendsProfileVMError.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestSuccessful() {
        friendsProfileVMSucceed.sendFriendRequest()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMSucceed.notificationMessage == "Successfully sent request!" &&
                self.friendsProfileVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testSendFriendRequestInvalidUserId() {
        mockFBError.validUserId = false
        friendsProfileVMError.sendFriendRequest()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMError.showingNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestError() {
        friendsProfileVMError.sendFriendRequest()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMError.notificationMessage == "User not found!" &&
                self.friendsProfileVMError.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestAlreadyFriends() {
        mockFBSucceed.userData = UserData(userId: "mockUserId2", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true, "mockUserId": true], blocked: [:])
        
        friendsProfileVMSucceed.sendFriendRequest()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMSucceed.notificationMessage == "You are already friends with this user!" &&
                self.friendsProfileVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestUserNotFound() {
        mockFBSucceed.userData = UserData(userId: nil, username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:])
        
        friendsProfileVMSucceed.sendFriendRequest()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMSucceed.notificationMessage == "User not found!" &&
                self.friendsProfileVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestAlreadySent() {
        mockFBSucceed.userData = UserData(userId: "mockUserId2", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:])
        mockFBSucceed.friendRequests = [FriendRequestData(requestId: "req123", senderId: "mockUserId", targetId: "mockUserId2", requestDate: "now", isComplete: false)]
        
        friendsProfileVMSucceed.sendFriendRequest()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMSucceed.notificationMessage == "Friend request already sent!" &&
                self.friendsProfileVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestAlreadyReceived() {
        mockFBSucceed.userData = UserData(userId: "mockUserId2", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: nil, blocked: [:])
        mockFBSucceed.friendRequests = [FriendRequestData(requestId: "req123", senderId: "mockUserId2", targetId: "mockUserId", requestDate: "now", isComplete: false)]
        
        friendsProfileVMSucceed.sendFriendRequest()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.friendsProfileVMSucceed.notificationMessage == "This user has already sent you a friend request!" &&
                self.friendsProfileVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
}


