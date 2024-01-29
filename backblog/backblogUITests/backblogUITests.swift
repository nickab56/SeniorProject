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
        let addLogButton = app.buttons["createLogButton"] // Assuming the button to confirm adding a log has this identifier
        addLogButton.tap()

        // Find the newly created log in the list of logs
        let newLogEntry = app.staticTexts[logName]
        XCTAssertTrue(newLogEntry.exists, "Newly created log should be visible in the list.")

        // Tap on the new log to go to its details view
        newLogEntry.tap()

        // Delete the newly created log
        let deleteLogButton = app.buttons["Delete Log"] // Assuming the button to delete a log has this identifier
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
        app.buttons["addLogButton"].tap() // Adjust based on the actual identifier for the add log button

        let logNameTextField = app.textFields["newLogNameTextField"] // Adjust based on the actual identifier for the log name text field
        XCTAssertTrue(logNameTextField.exists, "Log name text field is not found")
        logNameTextField.tap()
        logNameTextField.typeText("Favorite Movies")

        let createLogButton = app.buttons["createLogButton"] // Adjust based on the actual identifier for the create log button
        XCTAssertTrue(createLogButton.exists, "Create log button is not found")
        createLogButton.tap()

        // Navigate to the search view
        app.tabBars.buttons["Search"].tap() // Using the label or system image name to tap the search tab

        // Enter a search query in the search bar
        let searchField = app.textFields["movieSearchField"] // Accessibility identifier for the search field
        searchField.tap()
        searchField.typeText("Inception\n") // Simulate tapping the search button on the keyboard

        // Wait for search results to appear
        let movieResult = app.staticTexts["Inception"] // Assuming "Inception" will appear in the search results
        let exists = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: exists, object: movieResult)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0) // Adjust timeout as needed
        XCTAssertEqual(result, .completed, "Movie result did not appear in time.")

        let addToLogButton = app.buttons["Add to Log"].firstMatch // Using firstMatch to select the first button
        XCTAssertTrue(addToLogButton.exists, "Add to Log button is not found")
        addToLogButton.tap()

        // Select a log to add the movie to
        // This step requires knowing the identifier or label for the log list item
        // Assuming there's a log named "Favorite Movies" and it's visible without scrolling
        let favoriteMoviesLog = app.staticTexts["Favorite Movies"] // Adjust based on your actual UI
        XCTAssertTrue(favoriteMoviesLog.exists, "Favorite Movies log is not found")
        favoriteMoviesLog.tap()

        // Verify the movie has been added to the log
        // Navigate back to the log details to check if the movie is listed
        // This step might need adjustments based on how your app navigates and displays added movies in logs
        app.tabBars.buttons["landingViewTab"].tap() // Adjust based on your actual UI
        let favoriteMoviesLogInList = app.staticTexts["Favorite Movies"] // Adjust based on your actual UI
        favoriteMoviesLogInList.tap()
        
        let movieInLog = app.staticTexts["Inception"] // Adjust based on your actual UI
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
        searchField.typeText("Inception\n") // Adding '\n' to simulate tapping the search button on the keyboard

        // Check for the existence of search results
        let searchResult = app.staticTexts["Inception"] // Assuming "Inception" will be part of the search results
        let exists = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: exists, object: searchResult)

        // Wait for search results to appear
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0) // Adjust timeout as needed
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
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
