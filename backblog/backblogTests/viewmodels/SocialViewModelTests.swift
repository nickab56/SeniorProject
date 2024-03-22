//
//  SocialViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/21/24.
//

import XCTest
@testable import backblog

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
}

