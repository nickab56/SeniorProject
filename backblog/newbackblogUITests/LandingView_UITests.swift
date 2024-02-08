//
//  LandingView_UITests.swift
//  newbackblogUITests
//
//  Created by Nick Abegg on 2/7/24.
//

import XCTest

final class LandingView_UITests: XCTestCase {

    override func setUpWithError() throws {

        continueAfterFailure = false
        XCUIApplication().launch()

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_LandingView_AddLogButton_MakeNewLog() {
        
        let app = XCUIApplication()
        
        // Given: The app is launched, wait for the "addLogButton" to be visible on the landing page.
        let addLogButton = app.buttons["addLogButton"]
        let exists = NSPredicate(format: "exists == true")
        
        expectation(for: exists, evaluatedWith: addLogButton, handler: nil)
        waitForExpectations(timeout: 10) { error in
            if error != nil {
                XCTFail("Add Log button didn't appear in time")
            }
        }
        
        // When: We tap on the "addLogButton".
        addLogButton.tap()
        
        // And: Enter the name "Log 1" in the "newLogNameTextField", and then tap the "createLogButton".
        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should be visible after tapping Add Log button")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 1")
        
        let createLogButton = app.buttons["createLogButton"]
        XCTAssertTrue(createLogButton.waitForExistence(timeout: 5), "Create Log button should be visible after entering log name")
        createLogButton.tap()
        
        // Then: We should be returned to the landing page, and there should be a new log named "Log 1".
        let newLogEntry = app.staticTexts["Log 1"]
        XCTAssertTrue(newLogEntry.waitForExistence(timeout: 5), "Newly created log named 'Log 1' should exist on the landing page")
    }


    
    func test_LandingView_AddLogButton_DoNotMakeNewLog() {
        
        let app = XCUIApplication()
        app.launch()

        // Given: The app is launched, and we are on the landing page with an "addLogButton" visible.
        let addLogButton = app.buttons["addLogButton"]
        XCTAssertTrue(addLogButton.waitForExistence(timeout: 10), "Add Log button should exist on the landing page")

        // When: We tap on the "addLogButton" to navigate to the new log creation screen.
        addLogButton.tap()

        // And: Instead of creating a new log, we decide to tap the "cancelAddLogButton".
        let cancelAddLogButton = app.buttons["cancelAddLogButton"]
        XCTAssertTrue(cancelAddLogButton.waitForExistence(timeout: 5), "Cancel button should be visible on the new log creation screen")
        cancelAddLogButton.tap()

        // Then: We should be returned to the landing page without a new log being

        // An example assertion (you would need to adjust this to fit your app's UI):
        let newLogEntry = app.staticTexts["Log 1"]
        XCTAssertFalse(newLogEntry.exists, "New log should not exist after cancelling log creation")
    }

    
    func test_LandingView_DeleteLogButton_DeleteLog() {
        
        let app = XCUIApplication()
        app.launch()

        // Setup: Create a log named "Log 1" if it doesn't already exist.
        let addLogButton = app.buttons["addLogButton"]
        XCTAssertTrue(addLogButton.waitForExistence(timeout: 10), "Add Log button should exist on the landing page")
        
        addLogButton.tap()
        
        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should be visible after tapping Add Log button")
        
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 1")
        
        let createLogButton = app.buttons["createLogButton"]
        XCTAssertTrue(createLogButton.waitForExistence(timeout: 5), "Create Log button should be visible after entering log name")
        createLogButton.tap()

        // Ensure "Log 1" is created before proceeding.
        let logEntry = app.staticTexts["Log 1"]
        XCTAssertTrue(logEntry.waitForExistence(timeout: 10), "Log 1 should be created and visible on the landing page")

        // Given: A log named "Log 1" exists in the app.
        // (The log creation steps above serve as the 'Given' phase for this test.)

        // When: We tap on the log entry to select it.
        logEntry.tap()

        // And: Tap the "Delete Log" button to delete the selected log.
        let deleteLogButton = app.buttons["Delete Log"]
        XCTAssertTrue(deleteLogButton.exists, "Delete Log button should be visible after selecting a log")
        deleteLogButton.tap()
        
        
        // Wait for 1 second before checking that the log is deleted.
            let deletionWaitExpectation = XCTestExpectation(description: "Wait for 1 second before checking deletion")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                deletionWaitExpectation.fulfill()
            }
            wait(for: [deletionWaitExpectation], timeout: 2)

            // Then: "Log 1" should no longer exist in the app.
            XCTAssertFalse(app.staticTexts["Log 1"].exists, "Log 1 should be deleted and no longer visible in the app")
    }
    
    func test_LandingView_NavBar_NavigateNavBar() {
        
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars["Tab Bar"]
        
        // Navigate to the Login screen and verify by looking for a unique element.
        let person2FillButton = tabBar.buttons["person.2.fill"]
        person2FillButton.tap()
        let usernameTextField = app.textFields["usernameTextField"]
        XCTAssertTrue(usernameTextField.waitForExistence(timeout: 5), "Should be on the Login screen after tapping 'person.2.fill'")
        
        // Navigate to the HDR screen and verify by looking for a unique element.
        let hdrButton = tabBar.buttons["Hdr"]
        hdrButton.tap()
        let hdrScreenElement = app.buttons["addLogButton"] // Use a unique element from your HDR screen
        XCTAssertTrue(hdrScreenElement.waitForExistence(timeout: 5), "Should be on the HDR screen after tapping 'Hdr'")
        
        // Navigate back to the Login screen and verify.
        person2FillButton.tap()
        XCTAssertTrue(usernameTextField.waitForExistence(timeout: 5), "Should be on the Login screen after tapping 'person.2.fill', again")
        
        // Navigate to the Search screen and verify by looking for a unique element.
        let searchButton = tabBar.buttons["Search"]
        searchButton.tap()
        let searchField = app.textFields["movieSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Should be on the Search screen after tapping 'Search'")
        
        // Navigate back to the HDR screen and verify.
        hdrButton.tap()
        XCTAssertTrue(hdrScreenElement.waitForExistence(timeout: 5), "Should return to the HDR screen after tapping 'Hdr' again")
    }


}
