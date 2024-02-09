//
//  SearchView_UITests.swift
//  newbackblogUITests
//
//  Created by Nick Abegg on 2/8/24.
//

import XCTest

final class SearchView_UITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true

        let app = XCUIApplication()
        app.launchArguments.append("--uitesting-reset")
        app.launch()
    }

    override func tearDownWithError() throws {
        
    }

    func test_SearchViewMovieDetails_MovieDetails_SearchFindMovieDetails() throws {
        
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Search tab
        app.tabBars["Tab Bar"].buttons["Search"].tap()

        // Enter search query and select a movie from the search results
        let searchField = app.textFields["movieSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should exist")
        searchField.tap()
        searchField.typeText("Star Wars\n") // Assuming hitting return performs the search
        
        sleep(2)

        // Tap on the search result to view movie details
        // Adjust the identifier for the search result to match what's in your app
        let searchMovieTitle = app.staticTexts["SearchMovieTitle"].firstMatch
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: searchMovieTitle, handler: nil)
        waitForExpectations(timeout: 5)
        
        XCTAssertTrue(searchMovieTitle.exists, "Movie title should be displayed in the search results")

        searchMovieTitle.tap()
        
        sleep(1)

        // Verify Movie Title
        let movieTitle = app.staticTexts["movieTitle"]
        XCTAssertTrue(movieTitle.exists, "Movie title should be displayed")

        // Verify Release Date
        let movieReleaseDate = app.staticTexts["movieReleaseDate"]
        XCTAssertTrue(movieReleaseDate.exists, "Movie release date should be displayed")

        // Verify Runtime
        let movieRuntime = app.staticTexts["movieRunTime"]
        XCTAssertTrue(movieRuntime.exists, "Movie runtime should be displayed")

        // Verify Cast
        let movieCast = app.staticTexts["movieCast"]
        XCTAssertTrue(movieCast.exists, "Movie cast should be displayed")

        // Verify Director
        let movieDirector = app.staticTexts["movieDirector"]
        XCTAssertTrue(movieDirector.exists, "Movie director should be displayed")

        // Add more assertions as needed for genres, overview, etc.
    }
    
    func test_AddMovieToLogButton_SearchAndAddMovie() {
        let app = XCUIApplication()
        app.launch()

        // 1. Create a new log
        app.buttons["addLogButton"].tap()
        
        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 1\n") // Assuming "\n" confirms the entry

        let createLogButton = app.buttons["createLogButton"] // Adjust the identifier as needed
        createLogButton.tap()
        
        // 2. Navigate to Search tab and perform a search
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Search"].tap()
        
        let movieSearchField = app.textFields["movieSearchField"]
        XCTAssertTrue(movieSearchField.waitForExistence(timeout: 5), "Movie Search field should appear")
        movieSearchField.tap()
        movieSearchField.typeText("Star Wars\n") // Assuming "\n" performs the search
        
        sleep(1)
        
        // Tap the "Add to Log" button for the searched movie
        let addToLogButton = app.buttons["AddToLogButton"].firstMatch // Adjust identifier as needed
        XCTAssertTrue(addToLogButton.waitForExistence(timeout: 5), "Add to Log button should appear for searched movie")
        addToLogButton.tap()

        // Select a log from the list
        let logSelection = app.buttons["Log 1"] // Adjust identifier or label as needed
        XCTAssertTrue(logSelection.waitForExistence(timeout: 5), "Log selection should be present")
        logSelection.tap()

        // Confirm the selection by tapping the "Done" button
        let doneButton = app.buttons["Done"] // Adjust identifier or label as needed
        XCTAssertTrue(doneButton.exists, "Done button should be present")
        doneButton.tap()
        
        // 4. Verify the movie is added to the log
        tabBar.buttons["Hdr"].tap() // Adjust as needed for your app's tab
        
        let newLogEntry = app.staticTexts["Log 1"]
        XCTAssertTrue(newLogEntry.waitForExistence(timeout: 5), "Newly created log named 'Log 1' should exist on the landing page")
        
        newLogEntry.tap()
        
        // Assuming the movie title is displayed as a button in the log
        let addedMovie = app.buttons["Star Wars"]
        XCTAssertTrue(addedMovie.exists, "Added movie should appear in the log")
    }
    
    func test_AddMovieToMultipleLogs_MovieInBothLogs() throws {
        let app = XCUIApplication()
        app.launch()

        // Create the first log
        app.tabBars["Tab Bar"].buttons["Hdr"].tap() // Adjust as needed for your app's tab to access logs
        app.buttons["addLogButton"].tap() // Adjust the identifier as needed

        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 1\n") // Assuming "\n" confirms the entry

        let createLogButton = app.buttons["createLogButton"] // Adjust the identifier as needed
        createLogButton.tap()

        // Create the second log
        app.buttons["addLogButton"].tap() // Adjust the identifier as needed
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 2\n") // Assuming "\n" confirms the entry

        createLogButton.tap()

        // Navigate to the Search tab
        app.tabBars["Tab Bar"].buttons["Search"].tap()

        let movieSearchField = app.textFields["movieSearchField"]
        XCTAssertTrue(movieSearchField.waitForExistence(timeout: 5), "Movie Search field should appear")
        movieSearchField.tap()
        movieSearchField.typeText("Star Wars\n") // Assuming "\n" performs the search
        
        sleep(1)
        
        // Tap the "Add to Log" button for the searched movie
        let addToLogButton = app.buttons["AddToLogButton"].firstMatch // Adjust identifier as needed
        XCTAssertTrue(addToLogButton.waitForExistence(timeout: 5), "Add to Log button should appear for searched movie")
        addToLogButton.tap()

        // Select the first log
        let log1Button = app.buttons["Log 1"] // Adjust identifier or label as needed
        XCTAssertTrue(log1Button.waitForExistence(timeout: 5), "First log selection should be present")
        log1Button.tap()

        // Select the second log
        let log2Button = app.buttons["Log 2"] // Adjust identifier or label as needed
        XCTAssertTrue(log2Button.waitForExistence(timeout: 5), "Second log selection should be present")
        log2Button.tap()

        // Confirm the selection by tapping the "Done" button
        let doneButton = app.buttons["Done"] // Adjust identifier or label as needed
        XCTAssertTrue(doneButton.exists, "Done button should be present")
        doneButton.tap()

        // Verify the movie is added to the first log
        app.tabBars["Tab Bar"].buttons["Hdr"].tap() // Adjust as needed for your app's tab
        let log1Entry = app.staticTexts["Log 1"].firstMatch // Adjust as needed
        XCTAssertTrue(log1Entry.waitForExistence(timeout: 5), "Log 1 entry should exist")
        log1Entry.tap()
        let movieInLog1 = app.staticTexts["Star Wars"] // Adjust as needed
        XCTAssertTrue(movieInLog1.exists, "Movie should be in Log 1")

        // Navigate back and verify the movie is added to the second log
        app.navigationBars.buttons["Back"].tap() // Adjust the back button identifier if needed
        let log2Entry = app.staticTexts["Log 2"].firstMatch // Adjust as needed
        XCTAssertTrue(log2Entry.waitForExistence(timeout: 5), "Log 2 entry should exist")
        log2Entry.tap()
        let movieInLog2 = app.staticTexts["Star Wars"] // Adjust as needed
        XCTAssertTrue(movieInLog2.exists, "Movie should be in Log 2")
    }



}
