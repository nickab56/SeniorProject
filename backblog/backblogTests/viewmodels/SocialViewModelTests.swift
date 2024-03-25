//
//  SocialViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/21/24.
//

import XCTest
@testable import backblog
import CoreData

class SocialViewModelTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var socialVMSucceed: SocialViewModel!
    
    var mockFBError: MockFirebaseService!
    var socialVMError: SocialViewModel!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false

        socialVMSucceed = SocialViewModel(fb: mockFBSucceed)
        socialVMError = SocialViewModel(fb: mockFBError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        socialVMSucceed = nil
        mockFBError = nil
        socialVMError = nil
        super.tearDown()
    }
    
    func testFetchUserDataSuccess() {
        socialVMSucceed.fetchUserData()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.userData?.id == "mockUserId" &&
                self.socialVMSucceed.avatarSelection == 1
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testFetchUserDataNilUserId() {
        mockFBError.validUserId = false
        socialVMError.fetchUserData()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.userData == nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testFetchUserDataError() {
        socialVMError.fetchUserData()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.userData == nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testUpdateLogRequestSuccess() {
        let reqId = "req123"
        let reqType = "log"
        let accepted = true
        socialVMSucceed.updateRequest(reqId: reqId, reqType: reqType, accepted: accepted)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "Successfully updated request!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
        
        let expectation2 = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.showingNotification == false
            }), object: nil)
        wait(for: [expectation2], timeout: 5)
    }
    
    func testUpdateFriendRequestSuccess() {
        let reqId = "req123"
        let reqType = "friend"
        let accepted = true
        socialVMSucceed.updateRequest(reqId: reqId, reqType: reqType, accepted: accepted)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "Successfully updated request!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
        
        let expectation2 = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.showingNotification == false
            }), object: nil)
        wait(for: [expectation2], timeout: 5)
    }
    
    func testUpdateRequestError() {
        let reqId = "req123"
        let reqType = "friend"
        let accepted = true
        socialVMError.updateRequest(reqId: reqId, reqType: reqType, accepted: accepted)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.notificationMessage == "Error updating request" &&
                self.socialVMError.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
        
        let expectation2 = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.showingNotification == false
            }), object: nil)
        wait(for: [expectation2], timeout: 5)
    }
    
    func testSendFriendRequestSuccessful() {
        socialVMSucceed.sendFriendRequest(username: "mockUserId")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "Successfully sent request!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testSendFriendRequestInvalidUserId() {
        mockFBError.validUserId = false
        socialVMError.sendFriendRequest(username: "mockUserId")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.showingNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestError() {
        socialVMError.sendFriendRequest(username: "mockUserId")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.notificationMessage == "User not found!" &&
                self.socialVMError.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestAlreadyFriends() {
        mockFBSucceed.userData = UserData(userId: "mockUserId2", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true, "mockUserId": true], blocked: [:])
        
        socialVMSucceed.sendFriendRequest(username: "mockUserId")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "You are already friends with this user!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestUserNotFound() {
        mockFBSucceed.userData = UserData(userId: nil, username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:])
        
        socialVMSucceed.sendFriendRequest(username: "mockUserId")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "User not found!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestAlreadySent() {
        mockFBSucceed.userData = UserData(userId: "mockUserId2", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: ["bob123": true, "dude123": true], blocked: [:])
        mockFBSucceed.friendRequests = [FriendRequestData(requestId: "req123", senderId: "mockUserId", targetId: "mockUserId2", requestDate: "now", isComplete: false)]
        
        socialVMSucceed.sendFriendRequest(username: "mockUserId")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "Friend request already sent!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSendFriendRequestAlreadyReceived() {
        mockFBSucceed.userData = UserData(userId: "mockUserId2", username: "mockUsername", joinDate: "now", avatarPreset: 1, friends: nil, blocked: [:])
        mockFBSucceed.friendRequests = [FriendRequestData(requestId: "req123", senderId: "mockUserId2", targetId: "mockUserId", requestDate: "now", isComplete: false)]
        
        socialVMSucceed.sendFriendRequest(username: "mockUserId")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "This user has already sent you a friend request!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetUserId() {
        let successResult = socialVMSucceed.getUserId()
        mockFBError.validUserId = false
        let errorResult = socialVMError.getUserId()
        
        XCTAssertEqual(successResult, "mockUserId")
        XCTAssertEqual(errorResult, "")
    }
    
    func testUpdateUserSuccessful() {
        let username = "mockUserId"
        let newPassword = "newPassword"
        let password = "password"
        socialVMSucceed.avatarSelection = 2
        socialVMSucceed.updateUser(username: username, newPassword: newPassword, password: password)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "Successfully updated settings!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testUpdateUserInvalidUserId() {
        let username = "mockUserId"
        let newPassword = "newPassword"
        let password = "password"
        mockFBError.validUserId = false
        socialVMError.updateUser(username: username, newPassword: newPassword, password: password)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.showingNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testUpdateUserNoChangesMade() {
        let username = ""
        let newPassword = ""
        let password = "password"
        socialVMSucceed.updateUser(username: username, newPassword: newPassword, password: password)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "Please make changes before saving." &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testUpdateUserEmptyPasswordField() {
        let username = ""
        let newPassword = ""
        let password = ""
        socialVMSucceed.updateUser(username: username, newPassword: newPassword, password: password)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "Please enter your current password." &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testUpdateUserError() {
        let username = "mockUserId"
        let newPassword = "newPassword"
        let password = "password"
        socialVMError.updateUser(username: username, newPassword: newPassword, password: password)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.notificationMessage == "Error, please try again later." &&
                self.socialVMError.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testLogoutSuccessful() {
        socialVMSucceed.logout()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.isUnauthorized == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testLogoutUnauthorized() {
        mockFBError.validUserId = false
        socialVMError.logout()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.isUnauthorized == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testLogoutError() {
        socialVMError.logout()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.notificationMessage == "Error, please try logging out later." &&
                self.socialVMError.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testSyncLocalLogsToDBSuccessful() {
        socialVMSucceed.syncLocalLogsToDB()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMSucceed.notificationMessage == "Successfully transferred logs!" &&
                self.socialVMSucceed.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testSyncLocalLogsToDBError() {
        // Add test log
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            var items = try context.fetch(fetchRequest)
            let logData = LocalLogData(context: context)
            logData.log_id = 123
            logData.name = "My Log"
            logData.creation_date = "now"
            items.append(logData)
            try context.save()
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
        
        socialVMError.syncLocalLogsToDB()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.socialVMError.notificationMessage == "Error, please try syncing later." &&
                self.socialVMError.showingNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testGetLocalLogCountSuccess() {
        // Add test log
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            var items = try context.fetch(fetchRequest)
            let logData = LocalLogData(context: context)
            logData.log_id = 123
            logData.name = "My Log"
            logData.creation_date = "now"
            items.append(logData)
            try context.save()
        } catch let error as NSError {
            print("Error adding log: \(error), \(error.userInfo)")
        }
        
        let result = socialVMError.getLocalLogCount()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result > 0
            }), object: nil)
        wait(for: [expectation], timeout: 10)
        
        resetAllLogs()
    }
    
    private func resetAllLogs() {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
    }
    
}

