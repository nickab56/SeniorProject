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

        sleep(1)
        
        // Navigate to the Search tab
        app.tabBars["Tab Bar"].buttons["Search"].tap()

        // Enter search query and select a movie from the search results
        let searchField = app.textFields["movieSearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should exist")
        searchField.tap()
        searchField.typeText("Inception\n")
        
        sleep(2)

        // Tap on the search result to view movie details
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
        
    }
    
    func test_AddMovieToLogButton_SearchAndAddMovie() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // 1. Create a new log
        app.buttons["Create New Log"].tap()
        
        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 1\n")

        let createLogButton = app.buttons["createLogButton"]
        createLogButton.tap()
        
        // 2. Navigate to Search tab and perform a search
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Search"].tap()
        
        let movieSearchField = app.textFields["movieSearchField"]
        XCTAssertTrue(movieSearchField.waitForExistence(timeout: 5), "Movie Search field should appear")
        movieSearchField.tap()
        movieSearchField.typeText("Inception\n")

        sleep(3)
        
        // Tap the "Add to Log" button for the searched movie
        let addToLogButton = app.buttons["AddToLogButton"].firstMatch
        XCTAssertTrue(addToLogButton.waitForExistence(timeout: 5), "Add to Log button should appear for searched movie")
        addToLogButton.tap()

        // Select a log from the list
        let logSelection = app.buttons["Log 1"]
        XCTAssertTrue(logSelection.waitForExistence(timeout: 5), "Log selection should be present")
        logSelection.tap()

        // Confirm adding the movie to the log
        app.buttons["Add"].tap()
        
        // 4. Verify a movie is added to the log
        tabBar.buttons["Hdr"].tap()
        
        let newLogEntry = app.staticTexts["Log 1"]
        XCTAssertTrue(newLogEntry.waitForExistence(timeout: 5), "Newly created log named 'Log 1' should exist on the landing page")
        
        newLogEntry.tap()
        let movieInLog = app.cells.firstMatch
        XCTAssertTrue(movieInLog.exists, "There should be a movie in Log 1")
    }
    
    func test_AddMovieToLogButton_SearchAndDetailsAddMovie() {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // 1. Create a new log
        app.buttons["Create New Log"].tap()
        
        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 1\n")

        let createLogButton = app.buttons["createLogButton"]
        createLogButton.tap()
        
        // 2. Navigate to Search tab and perform a search
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Search"].tap()
        
        let movieSearchField = app.textFields["movieSearchField"]
        XCTAssertTrue(movieSearchField.waitForExistence(timeout: 5), "Movie Search field should appear")
        movieSearchField.tap()
        movieSearchField.typeText("Inception\n")

        sleep(3)
        
        
        let elementsQuery = app.otherElements
        // Tap the Inception Movie that appears after the search
        let inceptionMovie = elementsQuery.buttons["Inception, 2010"]
        XCTAssertTrue(inceptionMovie.waitForExistence(timeout: 5), "Inception movie should appear for searched movie")
        inceptionMovie.tap()
        
        // Tap the "Add to Log" button for the searched movie
        let addToLogButton = elementsQuery.buttons["ADD TO LOG"]
        XCTAssertTrue(addToLogButton.waitForExistence(timeout: 5), "Add to Log button should appear for searched movie")
        addToLogButton.tap()

        // Select a log from the list
        let logSelection = app.buttons["Log 1"]
        XCTAssertTrue(logSelection.waitForExistence(timeout: 5), "Log selection should be present")
        logSelection.tap()

        // Confirm adding the movie to the log
        app.buttons["Add"].tap()
        
        // 4. Verify a movie is added to the log
        tabBar.buttons["Hdr"].tap()
        
        let newLogEntry = app.staticTexts["Log 1"]
        XCTAssertTrue(newLogEntry.waitForExistence(timeout: 5), "Newly created log named 'Log 1' should exist on the landing page")
        
        newLogEntry.tap()
        let movieInLog = app.cells.firstMatch
        XCTAssertTrue(movieInLog.exists, "There should be a movie in Log 1")
    }

    
    func test_AddMovieToMultipleLogs_MovieInBothLogs() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(2)

        // Create the first log
        app.tabBars["Tab Bar"].buttons["Hdr"].tap()
        app.buttons["Create New Log"].tap()

        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 1\n")

        let createLogButton = app.buttons["createLogButton"]
        createLogButton.tap()

        // Create the second log
        app.buttons["addLogButton"].tap()
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear again")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Log 2\n")

        createLogButton.tap()

        // Navigate to the Search tab and perform a search
        app.tabBars["Tab Bar"].buttons["Search"].tap()

        let movieSearchField = app.textFields["movieSearchField"]
        XCTAssertTrue(movieSearchField.waitForExistence(timeout: 5), "Movie Search field should appear")
        movieSearchField.tap()
        movieSearchField.typeText("Inception\n")

        sleep(3)
        
        // Tap the "Add to Log" button for the searched movie
        let addToLogButton = app.buttons["AddToLogButton"].firstMatch
        XCTAssertTrue(addToLogButton.waitForExistence(timeout: 5), "Add to Log button should appear for searched movie")
        addToLogButton.tap()

        // Select and add the movie to the first log
        let log1Button = app.buttons["Log 1"]
        XCTAssertTrue(log1Button.waitForExistence(timeout: 5), "First log selection should be present")
        log1Button.tap()

        // Select and add the movie to the second log
        let log2Button = app.buttons["Log 2"]
        XCTAssertTrue(log2Button.waitForExistence(timeout: 5), "Second log selection should be present")
        log2Button.tap()

        // Confirm adding the movie to the logs
        app.buttons["Add"].tap()
        
        
        // Verify a movie is added to the first log
        app.tabBars["Tab Bar"].buttons["Hdr"].tap()
        let log1Entry = app.staticTexts["Log 1"].firstMatch
        XCTAssertTrue(log1Entry.waitForExistence(timeout: 5), "Log 1 entry should exist")
        log1Entry.tap()
        let movieInLog1 = app.cells.firstMatch
        XCTAssertTrue(movieInLog1.exists, "There should be a movie in Log 1")

        // Navigate back and verify a movie is added to the second log
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let log2Entry = app.staticTexts["Log 2"].firstMatch
        XCTAssertTrue(log2Entry.waitForExistence(timeout: 5), "Log 2 entry should exist")
        log2Entry.tap()
        let movieInLog2 = app.cells.firstMatch
        XCTAssertTrue(movieInLog2.exists, "There should be a movie in Log 2")
    }

    
    func test_AddMovieToLogWithDuplicationCheck() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Create the first log
        app.tabBars["Tab Bar"].buttons["Hdr"].tap()
        app.buttons["Create New Log"].tap()

        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Test Log\n")

        let createLogButton = app.buttons["createLogButton"]
        createLogButton.tap()

        // Step 2: Navigate to Search tab and add "Star Wars" to the log
        app.tabBars["Tab Bar"].buttons["Search"].tap()

        let movieSearchField = app.textFields["movieSearchField"]
        XCTAssertTrue(movieSearchField.waitForExistence(timeout: 5), "Movie Search field should appear")
        movieSearchField.tap()
        movieSearchField.typeText("Inception\n")
        
        sleep(1)
        
        let addToLogButton = app.buttons["AddToLogButton"].firstMatch
        XCTAssertTrue(addToLogButton.waitForExistence(timeout: 5), "Add to Log button should appear for searched movie")
        addToLogButton.tap()

        let logSelection = app.buttons["Test Log"]
        XCTAssertTrue(logSelection.waitForExistence(timeout: 5), "Log selection should be present")
        logSelection.tap()

        app.buttons["Add"].tap()

        // Step 3: Attempt to add "Star Wars" again to the same log
        addToLogButton.tap()
        logSelection.tap()

        // Step 4: Check for duplication notification
        let notificationText = app.staticTexts["AlreadyInLogText"]
        XCTAssertTrue(notificationText.waitForExistence(timeout: 5), "Notification for duplicate movie should be displayed")
    }

    
    func test_AddMovieToLogWithoutDuplication() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)

        // Create a new log
        app.tabBars["Tab Bar"].buttons["Hdr"].tap()
        app.buttons["Create New Log"].tap()

        let newLogNameTextField = app.textFields["newLogNameTextField"]
        XCTAssertTrue(newLogNameTextField.waitForExistence(timeout: 5), "New Log Name text field should appear")
        newLogNameTextField.tap()
        newLogNameTextField.typeText("Test Log\n")

        let createLogButton = app.buttons["createLogButton"]
        createLogButton.tap()

        // Step 2: Navigate to Search tab and add "Star Wars" to the log
        app.tabBars["Tab Bar"].buttons["Search"].tap()

        let movieSearchField = app.textFields["movieSearchField"]
        XCTAssertTrue(movieSearchField.waitForExistence(timeout: 5), "Movie Search field should appear")
        movieSearchField.tap()
        movieSearchField.typeText("Star Wars\n")
        
        sleep(1)
        
        let addToLogButton = app.buttons["AddToLogButton"].firstMatch
        XCTAssertTrue(addToLogButton.waitForExistence(timeout: 5), "Add to Log button should appear for searched movie")
        addToLogButton.tap()

        let logSelection = app.buttons["Test Log"]
        XCTAssertTrue(logSelection.waitForExistence(timeout: 5), "Log selection should be present")
        logSelection.tap()

        app.buttons["Add"].tap()

        // Step 3: Ensure the duplication notification does not appear
        let notificationText = app.staticTexts["AlreadyInLogText"]
        XCTAssertFalse(notificationText.exists, "Notification for duplicate movie should not be displayed")
    }
    
    func test_CategoryView()
    {
        
        let app = XCUIApplication()
        app.launch()
        
        sleep(1)
        
         app.tabBars.buttons["Search"].tap()
         
         // Define the genre identifiers and names for easier iteration
         let genres = [
             ("Action", "GenreButton_Action"),
             ("Horror", "GenreButton_Horror"),
             ("Sci-Fi", "GenreButton_SciFi"),
             ("Fantasy", "GenreButton_Fantasy"),
             ("Animation", "GenreButton_Animation"),
             ("Comedy", "GenreButton_Comedy"),
             ("Crime", "GenreButton_Crime"),
             ("Drama", "GenreButton_Drama"),
             ("Family", "GenreButton_Family"),
             ("Western", "GenreButton_Western")
         ]
         
         for (genreName, genreIdentifier) in genres {
             let genreButton = app.buttons[genreIdentifier]
             XCTAssertTrue(genreButton.exists, "\(genreName) button does not exist")
             genreButton.tap()
             
             let firstMovie = app.staticTexts["SearchMovieTitle"].firstMatch
             let exists = NSPredicate(format: "exists == 1")
             expectation(for: exists, evaluatedWith: firstMovie, handler: nil)
             waitForExpectations(timeout: 5, handler: nil)
             
             if app.navigationBars.buttons["Search"].exists {
                 app.navigationBars.buttons["Search"].tap()
             }
         }
        
    }



}
