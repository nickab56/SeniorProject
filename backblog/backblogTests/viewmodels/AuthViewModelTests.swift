//
//  AuthViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/21/24.
//

import XCTest
@testable import backblog

class AuthViewModelTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var mockFBExists: MockFirebaseService!
    var authViewModelSucceed: AuthViewModel!
    
    var authViewModelExists: AuthViewModel!
    
    var mockFBError: MockFirebaseService!
    var authViewModelError: AuthViewModel!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        mockFBExists = MockFirebaseService()
        mockFBError = MockFirebaseService()
        
        mockFBError.shouldSucceed = false
        mockFBError.exists = false
        
        authViewModelExists = AuthViewModel(fb: mockFBExists)
        mockFBSucceed.exists = false
        authViewModelSucceed = AuthViewModel(fb: mockFBSucceed)
        authViewModelError = AuthViewModel(fb: mockFBError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        authViewModelSucceed = nil
        authViewModelExists = nil
        mockFBError = nil
        authViewModelError = nil
        super.tearDown()
    }
    
    func testAttemptLoginSuccess() {
        let email = "test@test.com"
        let password = "password"
        authViewModelSucceed.attemptLogin(email: email, password: password)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.authViewModelSucceed.loginMessage == "Login Successful, redirecting..." &&
                self.authViewModelSucceed.isLoggedInToSocial == true
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testAttemptLoginError() {
        let email = "test@test.com"
        let password = "password"
        authViewModelError.attemptLogin(email: email, password: password)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.authViewModelError.loginMessage == "Failed to login. Please check your email and password" &&
                self.authViewModelError.isLoggedInToSocial == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testAttemptSignupSuccess() {
        let email = "test@test.com"
        let password = "password"
        let displayName = "Bob123"
        authViewModelSucceed.attemptSignup(email: email, password: password, displayName: displayName)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.authViewModelSucceed.signupSuccessful == true &&
                self.authViewModelSucceed.signupMessage == "Signup Successful"
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testAttemptSignupUsernameAlreadyExists() {
        let email = "test@test.com"
        let password = "password"
        let displayName = "Bob123"
        authViewModelExists.attemptSignup(email: email, password: password, displayName: displayName)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.authViewModelExists.signupMessage == "Username already exists" &&
                self.authViewModelExists.signupSuccessful == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testAttemptSignupError() {
        let email = "test@test.com"
        let password = "password"
        let displayName = "Bob123"
        authViewModelError.attemptSignup(email: email, password: password, displayName: displayName)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.authViewModelError.signupMessage.contains("Signup Failed") &&
                self.authViewModelError.signupSuccessful == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
}
