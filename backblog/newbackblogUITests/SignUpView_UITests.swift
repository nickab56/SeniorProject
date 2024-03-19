//
//  SignUpView_UITests.swift
//  newbackblogUITests
//
//  Created by Nick Abegg on 2/27/24.
//

import XCTest

final class SignUpView_UITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        
    }

    func testSignupViewUIElements() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()
        
        sleep(1)
        app.staticTexts["Signup"].tap() // Tapping on the Signup button/link

        // Assert that all UI elements are present
        let emailTextField = app.textFields["signupUsernameTextField"]
        XCTAssertTrue(emailTextField.exists, "Email text field does not exist")

        let passwordSecureField = app.secureTextFields["signupPasswordSecureField"]
        XCTAssertTrue(passwordSecureField.exists, "Password secure field does not exist")

        let displayNameTextField = app.textFields["signupDisplayNameTextField"]
        XCTAssertTrue(displayNameTextField.exists, "Display Name text field does not exist")

        let continueButton = app.buttons["signupContinueButton"]
        XCTAssertTrue(continueButton.exists, "Continue button does not exist")
    }
    
    func testSignupFailsMissingEmail() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()
        
        sleep(1)
        app.staticTexts["Signup"].tap() // Tapping on the Signup button/link

        // Fill only the password and display name fields
        let passwordSecureField = app.secureTextFields["signupPasswordSecureField"]
        passwordSecureField.tap()
        passwordSecureField.typeText("password123")

        let displayNameTextField = app.textFields["signupDisplayNameTextField"]
        displayNameTextField.tap()
        displayNameTextField.typeText("Nick")

        // Try to continue without filling the email field
        app.buttons["signupContinueButton"].tap()

        // Check for the error message
        let errorMessage = app.staticTexts["signupMessage"]
        XCTAssertTrue(errorMessage.exists, "Error message should be displayed")
    }

    func testSignupFailsMissingPassword() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()
        
        sleep(1)
        app.staticTexts["Signup"].tap() // Tapping on the Signup button/link

        // Fill only the email and display name fields
        let emailTextField = app.textFields["signupUsernameTextField"]
        emailTextField.tap()
        emailTextField.typeText("nick@example.com")

        let displayNameTextField = app.textFields["signupDisplayNameTextField"]
        displayNameTextField.tap()
        displayNameTextField.typeText("Nick")

        // Try to continue without filling the password field
        app.buttons["signupContinueButton"].tap()

        // Check for the error message
        let errorMessage = app.staticTexts["signupMessage"]
        XCTAssertTrue(errorMessage.exists, "Error message should be displayed")
    }

    func testSignupFailsMissingDisplayName() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()
        
        sleep(1)
        app.staticTexts["Signup"].tap() // Tapping on the Signup button/link

        // Fill only the email and password fields
        let emailTextField = app.textFields["signupUsernameTextField"]
        emailTextField.tap()
        emailTextField.typeText("nick@example.com")

        let passwordSecureField = app.secureTextFields["signupPasswordSecureField"]
        passwordSecureField.tap()
        passwordSecureField.typeText("password123")

        // Try to continue without filling the display name field
        app.buttons["signupContinueButton"].tap()

        // Check for the error message
        let errorMessage = app.staticTexts["signupMessage"]
        XCTAssertTrue(errorMessage.exists, "Error message should be displayed")
    }

    func testSignupFailsAllFieldsMissing() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()
        
        sleep(1)
        app.staticTexts["Signup"].tap() // Tapping on the Signup button/link

        // Try to continue without filling any fields
        app.buttons["signupContinueButton"].tap()

        // Check for the error message
        let errorMessage = app.staticTexts["signupMessage"]
        XCTAssertTrue(errorMessage.exists, "Error message should be displayed")
    }
    

}
