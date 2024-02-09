//
//  LoginView_UITests.swift
//  newbackblogUITests
//
//  Created by Nick Abegg on 2/8/24.
//

import XCTest

final class LoginView_UITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        
    }

    func test_LoginView_LoginButton_LogsTheUserIn() {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()
        
        sleep(1)

        // Tap on the username text field and enter the username
        let usernameTextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernameTextField.waitForExistence(timeout: 5), "Username text field should be present")
        usernameTextField.tap()
        usernameTextField.typeText("nick.abegg@email.com")

        // Tap on the password secure text field and enter the password
        let passwordSecureField = app.secureTextFields["passwordSecureField"]
        XCTAssertTrue(passwordSecureField.waitForExistence(timeout: 5), "Password secure text field should be present")
        passwordSecureField.tap()
        passwordSecureField.typeText("password")

        // Tap on the login button to attempt to log in
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Login button should be present")
        loginButton.tap()

        // Add assertions here to verify successful login, such as checking for the presence of an element that only appears upon successful login
    }
    
    func test_LoginView_LoginButton_LoginFailsMissingUsername() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()
        
        sleep(1)

        // Leave the username text field blank and enter a password
        let passwordSecureField = app.secureTextFields["passwordSecureField"]
        XCTAssertTrue(passwordSecureField.waitForExistence(timeout: 5), "Password secure text field should be present")
        passwordSecureField.tap()
        passwordSecureField.typeText("password")

        // Tap on the login button
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()

        // Check for the login failure message indicating the missing username
        let loginFailureMessage = app.staticTexts["loginMessage"]
        XCTAssertTrue(loginFailureMessage.waitForExistence(timeout: 5), "Login failure message should be present")
        XCTAssertEqual(loginFailureMessage.label, "Please fill all fields")
    }

    
    func test_LoginView_LoginButton_LoginFailsMissingPassword() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()

        // Enter a username but leave the password text field blank
        let usernameTextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernameTextField.waitForExistence(timeout: 5), "Username text field should be present")
        usernameTextField.tap()
        usernameTextField.typeText("nick.abegg@email.com")

        // Tap on the login button
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()

        // Check for the login failure message indicating the missing password
        let loginFailureMessage = app.staticTexts["loginMessage"]
        XCTAssertTrue(loginFailureMessage.waitForExistence(timeout: 5), "Login failure message should be present")
        XCTAssertEqual(loginFailureMessage.label, "Please fill all fields")
    }
    
    func test_LoginView_LoginButton_LoginFailsMissingBoth() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(2)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()

        // Leave both the username and password text fields blank

        // Tap on the login button
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()

        // Check for the login failure message indicating the missing credentials
        let loginFailureMessage = app.staticTexts["loginMessage"]
        XCTAssertTrue(loginFailureMessage.waitForExistence(timeout: 5), "Login failure message should be present")
        XCTAssertEqual(loginFailureMessage.label, "Please fill all fields")
    }



}
