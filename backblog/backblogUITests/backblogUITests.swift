//
//  backblogUITests.swift
//  backblogUITests
//
//  Created by Nick Abegg on 12/18/23.
//

import XCTest

final class backblogUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNavBarSearchPage() throws {
        let app = XCUIApplication()
        app.launch()
    
        let searchButton = app.tabBars["Tab Bar"].buttons["Search"]
        XCTAssertTrue(searchButton.exists)
        
        searchButton.tap()
        
        }
    
    func testNavBarSignInPage() throws {
        let app = XCUIApplication()
        app.launch()
        
        let friendButton = app.tabBars["Tab Bar"].buttons["person.2.fill"]
        XCTAssertTrue(friendButton.exists)
        
        friendButton.tap()
        }
    
    func testAddingLog() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["addLogButton"].tap()

        let addLogPopup = app.collectionViews

        let logNameTextField = addLogPopup.textFields["newLogNameTextField"]
        XCTAssertTrue(logNameTextField.exists)
        logNameTextField.tap()
        logNameTextField.typeText("Log 1")

        let addButton = addLogPopup.buttons["addLogButton"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()

        // Verify that the new log appears in the main content
        let tempLog = app.scrollViews.otherElements.scrollViews.otherElements.staticTexts["Log 1"]
        XCTAssertTrue(tempLog.exists)
    }
    
    func testCancelAddingLog() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["addLogButton"].tap()

        let cancelAddLogButton = app.buttons["cancelAddLogButton"]

        XCTAssertTrue(cancelAddLogButton.exists, "The cancel button does not exist.")

        cancelAddLogButton.tap()
    }


    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
