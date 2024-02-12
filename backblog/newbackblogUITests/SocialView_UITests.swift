//
//  SocialView_UITests.swift
//  newbackblogUITests
//
//  Created by Nick Abegg on 2/8/24.
//

import XCTest

final class SocialView_UITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        
    }
    
    func testSocialViewTabulation() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()
        
        sleep(1)

        // Tap on the username text field and enter the username
        let usernameTextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernameTextField.waitForExistence(timeout: 5), "Username text field should be present")
        usernameTextField.tap()
        usernameTextField.typeText("apple@apple.com")

        // Tap on the password secure text field and enter the password
        let passwordSecureField = app.secureTextFields["passwordSecureField"]
        XCTAssertTrue(passwordSecureField.waitForExistence(timeout: 5), "Password secure text field should be present")
        passwordSecureField.tap()
        passwordSecureField.typeText("apple123")

        // Tap on the login button to attempt to log in
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Login button should be present")
        loginButton.tap()

        // After login, wait for the first UI element of the logged-in state to ensure login was successful
        let logsTabElement = app.staticTexts["NoLogsText"] // Assuming this element is quickly available after login
        XCTAssertTrue(logsTabElement.waitForExistence(timeout: 10), "Should be in the Logs tab after login")

        // Switch to Friends tab and check for Friends section header
        app.segmentedControls.buttons["Friends"].tap()
        XCTAssertTrue(app.staticTexts["FriendsSectionHeader"].waitForExistence(timeout: 10), "Friends section header should be visible in the Friends tab")

        // Switch back to Logs tab and verify "No logs found" again
        app.segmentedControls.buttons["Logs"].tap()
        XCTAssertTrue(logsTabElement.exists, "No logs text should be visible again in the Logs tab after switching back")
        }
    
    func testChangeAvatarProcess() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the social view tab
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()

        // Log in
        let usernameTextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernameTextField.waitForExistence(timeout: 5))
        usernameTextField.tap()
        usernameTextField.typeText("apple@apple.com")

        let passwordSecureField = app.secureTextFields["passwordSecureField"]
        XCTAssertTrue(passwordSecureField.waitForExistence(timeout: 5))
        passwordSecureField.tap()
        passwordSecureField.typeText("apple123")

        app.buttons["loginButton"].tap()

        // Navigate to settings
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 10))
        app.buttons["Settings"].tap()

        // Change the avatar
        app.buttons["Change Avatar"].tap()

        let selectedAvatarIndex = Int.random(in: 1...6)
        let avatarId = "avatar\(selectedAvatarIndex)"
        
        // Select the randomly chosen avatar
        app.images[avatarId].tap()

        // Enter old password
        let oldPasswordSecureField = app.secureTextFields["Enter Old Password"]
        XCTAssertTrue(oldPasswordSecureField.waitForExistence(timeout: 5))
        oldPasswordSecureField.tap()
        oldPasswordSecureField.typeText("apple123")

        // Save the settings
        app.buttons["SAVE"].tap()
        
        let statusMessage = app.staticTexts["StatusMessage"]
        XCTAssertTrue(statusMessage.waitForExistence(timeout: 5))
        XCTAssertEqual(statusMessage.label, "Successfully updated settings!")
            
        // Go back to verify the avatar has been changed
        app.buttons["Back"].tap()
        XCTAssertTrue(app.images["UserProfileImage"].waitForExistence(timeout: 5))
        // Here you would ideally verify the avatar has changed, but this is not straightforward in UI tests because
        // UI tests do not have access to the app's internal state. You might need to look for visual changes or other indicators.
    }

    
    
}
