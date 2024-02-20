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

        // After login, wait for the first UI element of the logged-in state to ensure login was successful
        let logsTabElement = app.staticTexts["NoLogsText"] // Assuming this element is quickly available after login
        XCTAssertTrue(logsTabElement.waitForExistence(timeout: 10), "Should be in the Logs tab after login")

        // Switch to Friends tab and check for Friends section header
        app.segmentedControls.buttons["Friends"].tap()
        sleep(2)
        XCTAssertTrue(app.staticTexts["NoFriendsText"].waitForExistence(timeout: 10), "NoFriendsText should be visible in the Friends tab")

        // Switch back to Logs tab and verify "No logs found" again
        app.segmentedControls.buttons["Logs"].tap()
        XCTAssertTrue(logsTabElement.exists, "No logs text should be visible again in the Logs tab after switching back")
        }
    
    func testChangeAvatarProcess() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(2)

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

        // Open change avatar sheet
        app.buttons["Change Avatar"].tap()
        
        sleep(1)
        
        // Wait for the avatar selection view to appear
        let avatarSelectionView = app.otherElements["AvatarSelectionView"]
        XCTAssertTrue(avatarSelectionView.waitForExistence(timeout: 5), "The avatar selection view should be present")

        // Select an avatar
        let selectedAvatarIndex = Int.random(in: 1...6)
        let avatarId = "avatar\(selectedAvatarIndex)"
        app.images[avatarId].tap()
        
        sleep(1)

        // Verify that the sheet is dismissed and we're back on the settings page
        XCTAssertTrue(app.buttons["Change Avatar"].waitForExistence(timeout: 5))

        // Verify the selected avatar is displayed in settings
        let selectedAvatarImage = app.images["SettingsProfilePicture"]
        XCTAssertTrue(selectedAvatarImage.exists, "Selected avatar should be visible in settings")

        // Further verification can be done by checking if the selected avatar's image is the one expected.
        // This might involve comparing image assets or other methods not directly supported by XCTest UI testing.
    }


    
    
}
