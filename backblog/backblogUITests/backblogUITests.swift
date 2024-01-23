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

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        
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

        let canceladdlogbutton = app.navigationBars["Add New Log"]/*@START_MENU_TOKEN@*/.buttons["cancelAddLogButton"]/*[[".otherElements[\"Cancel\"]",".buttons[\"Cancel\"]",".buttons[\"cancelAddLogButton\"]",".otherElements[\"cancelAddLogButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(canceladdlogbutton.exists)
        canceladdlogbutton.tap()
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
