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
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddingAndDeletingLog() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the view where logs are added
        app.buttons["addLogButton"].tap()

        // Enter the details for the new log
        let logName = "New Log Test"
        let logNameTextField = app.textFields["newLogNameTextField"]
        logNameTextField.tap()
        logNameTextField.typeText(logName)

        // Save the new log
        let addLogButton = app.buttons["createLogButton"]
        addLogButton.tap()

        // Find the newly created log in the list of logs
        let newLogEntry = app.staticTexts[logName]
        XCTAssertTrue(newLogEntry.exists, "Newly created log should be visible in the list.")

        // Tap on the new log to go to its details view
        newLogEntry.tap()

        // Delete the newly created log
        let deleteLogButton = app.buttons["Delete Log"]
        deleteLogButton.tap()

        // After performing the delete operation
        let logDisappeared = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: logDisappeared, object: newLogEntry)

        // Wait for up to 5 seconds for the log to disappear
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Failed to delete the log within the expected time.")

    }
    
    func testAddingMovieToLog() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Create "Favorite Movies" log
        app.buttons["addLogButton"].tap()

        let logNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(logNameTextField.exists, "Log name text field is not found")
        logNameTextField.tap()
        logNameTextField.typeText("Favorite Movies")

        let createLogButton = app.buttons["createLogButton"]
        XCTAssertTrue(createLogButton.exists, "Create log button is not found")
        createLogButton.tap()

        // Navigate to the search view
        app.tabBars.buttons["Search"].tap()

        // Enter a search query in the search bar
        let searchField = app.textFields["movieSearchField"]
        searchField.tap()
        searchField.typeText("Inception\n")

        // Wait for search results to appear
        let movieResult = app.staticTexts["Inception"]
        let exists = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: exists, object: movieResult)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Movie result did not appear in time.")

        let addToLogButton = app.buttons["Add to Log"].firstMatch
        XCTAssertTrue(addToLogButton.exists, "Add to Log button is not found")
        addToLogButton.tap()

        // Select a log to add the movie to
        let favoriteMoviesLog = app.staticTexts["Favorite Movies"]
        XCTAssertTrue(favoriteMoviesLog.exists, "Favorite Movies log is not found")
        favoriteMoviesLog.tap()

        // Verify the movie has been added to the log
        app.tabBars.buttons["landingViewTab"].tap()
        let favoriteMoviesLogInList = app.staticTexts["Favorite Movies"]
        favoriteMoviesLogInList.tap()
        
        let movieInLog = app.staticTexts["Inception"]
        XCTAssertTrue(movieInLog.exists, "Movie should be listed in the log")
    }


    
    func testNavBarSearchPage() throws {
        let app = XCUIApplication()
        app.launch()
    
        let searchButton = app.tabBars["Tab Bar"].buttons["Search"]
        XCTAssertTrue(searchButton.exists)
        
        searchButton.tap()
        
        }
    
    func testMovieSearch() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the search view
        app.tabBars.buttons["Search"].tap()

        // Enter a search query in the search bar
        let searchField = app.textFields["movieSearchField"]
        searchField.tap()
        searchField.typeText("Inception\n")

        // Check for the existence of search results
        let searchResult = app.staticTexts["Inception"]
        let exists = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: exists, object: searchResult)

        // Wait for search results to appear
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Search results did not appear in time.")
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

        let addButton = addLogPopup.buttons["createLogButton"]
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
            // This measures how long it takes to launch the app.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
