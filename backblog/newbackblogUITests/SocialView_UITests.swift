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
        let logsTabElement = app.staticTexts["NoLogsText"]
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
    }
    
        func testAddFriendUIElements() throws {
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
            
            app.segmentedControls.buttons["Friends"].tap()
            sleep(2)
            
            // Tap on the 'Add Friend' button to open the add friend sheet
            app.buttons["addFriendButton"].tap()
            
            // Check if the text field for entering username is present
            let addUsernameTextField = app.textFields["addUsernameTextField"]
            XCTAssertTrue(addUsernameTextField.exists, "Username text field should be present on the Add Friend sheet")
            
            // Check if the 'Send Friend Request' button is present
            let sendFriendRequestButton = app.buttons["sendFriendRequest"]
            XCTAssertTrue(sendFriendRequestButton.exists, "Send Friend Request button should be present on the Add Friend sheet")
            
            // Check if the 'Cancel' button is present
            let cancelButton = app.buttons["cancelSendFriendRequest"]
            XCTAssertTrue(cancelButton.exists, "Cancel button should be present on the Add Friend sheet")
            
            cancelButton.tap()
        }
    
    func test_FriendsProfileView_BlockandRemoveandAdd() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(2)
        app.tabBars["Tab Bar"].buttons["person.2.fill"].tap()

        // Enter username/email
        let usernameTextField = app.textFields["usernameTextField"] // Make sure this identifier matches your actual UI
        XCTAssertTrue(usernameTextField.waitForExistence(timeout: 5), "Username text field should be present")
        usernameTextField.tap()
        usernameTextField.typeText("apple@apple.com")

        // Enter password
        let passwordSecureField = app.secureTextFields["passwordSecureField"] // Make sure this identifier matches your actual UI
        XCTAssertTrue(passwordSecureField.waitForExistence(timeout: 5), "Password secure text field should be present")
        passwordSecureField.tap()
        passwordSecureField.typeText("apple123")

        // Tap on the login button
        let loginButton = app.buttons["loginButton"] // Make sure this identifier matches your actual UI
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Login button should be present")
        loginButton.tap()
        
        app.segmentedControls.buttons["Friends"].tap()
        sleep(2)

        let firstFriendProfile = app.buttons["FriendProfileElement"].firstMatch
        XCTAssertTrue(firstFriendProfile.waitForExistence(timeout: 10), "At least one friend profile should be present in the list")

        // Tap on the first friend profile
        firstFriendProfile.tap()

        // Assert and tap the Remove Friend Button
        let removeFriendButton = app.buttons["RemoveFriendButton"]
        XCTAssertTrue(removeFriendButton.waitForExistence(timeout: 5), "Remove Friend Button should be present")
        removeFriendButton.tap()

        // Tap Cancel on the Remove Friend alert
        let cancelRemoveFriendButton = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancelRemoveFriendButton.waitForExistence(timeout: 5), "Cancel button in Remove Friend alert should be present")
        cancelRemoveFriendButton.tap()

        // Assert and tap the Block User Button
        let blockUserButton = app.buttons["BlockUserButton"]
        XCTAssertTrue(blockUserButton.waitForExistence(timeout: 5), "Block User Button should be present")
        blockUserButton.tap()

        // Tap Cancel on the Block User alert
        let cancelBlockUserButton = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancelBlockUserButton.waitForExistence(timeout: 5), "Cancel button in Block User alert should be present")
        cancelBlockUserButton.tap()
    }

}
