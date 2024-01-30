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
    
    // you need to run testAddingLog func first to pass this test
    func testDeletingLog() throws {
        let app = XCUIApplication()
        app.launch()
        
        let logButton = app/*@START_MENU_TOKEN@*/.scrollViews/*[[".otherElements[\"mainContentViewTab\"].scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.otherElements.scrollViews.otherElements.staticTexts["Log 1"].firstMatch
        XCTAssertTrue(logButton.exists)

        
        
        logButton.tap()

        let deleteButton = app/*@START_MENU_TOKEN@*/.buttons["deleteLogButton"]/*[[".buttons[\"Delete Log\"]",".buttons[\"deleteLogButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(deleteButton.exists)
        deleteButton.tap()
        
    }
    
    func testCancelAddingLog() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["addLogButton"].tap()

        let canceladdlogbutton = app.collectionViews/*@START_MENU_TOKEN@*/.buttons["cancelAddLogButton"]/*[[".cells",".buttons[\"Cancel\"]",".buttons[\"cancelAddLogButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        
        XCTAssertTrue(canceladdlogbutton.exists)
        canceladdlogbutton.tap()
    }


    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch the app.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testFriendPage() throws {
        let app = XCUIApplication()
        app.launch()
        
        let navSocial = app.tabBars["Tab Bar"].buttons["person.2.fill"]
        XCTAssertTrue(navSocial.exists)
        navSocial.tap()
        
        // Temp waiting for Auth
        let loginButton = app/*@START_MENU_TOKEN@*/.buttons["loginButton"]/*[[".otherElements[\"socialViewTab\"]",".buttons[\"Log In\"]",".buttons[\"loginButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        let friendSection = app/*@START_MENU_TOKEN@*/.buttons["Friends"]/*[[".otherElements[\"socialViewTab\"]",".segmentedControls[\"logsFriendsTabPicker\"].buttons[\"Friends\"]",".buttons[\"Friends\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(friendSection.exists)
        friendSection.tap()
    }
    
    func testAddFriend() throws {
        let app = XCUIApplication()
        app.launch()
        
        let navSocial = app.tabBars["Tab Bar"].buttons["person.2.fill"]
        XCTAssertTrue(navSocial.exists)
        navSocial.tap()
        
        // Temp waiting for Auth
        let loginButton = app/*@START_MENU_TOKEN@*/.buttons["loginButton"]/*[[".otherElements[\"socialViewTab\"]",".buttons[\"Log In\"]",".buttons[\"loginButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        let friendSection = app/*@START_MENU_TOKEN@*/.buttons["Friends"]/*[[".otherElements[\"socialViewTab\"]",".segmentedControls[\"logsFriendsTabPicker\"].buttons[\"Friends\"]",".buttons[\"Friends\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(friendSection.exists)
        friendSection.tap()
        
        
        let addFriendButton = app/*@START_MENU_TOKEN@*/.buttons["person.badge.plus"]/*[[".otherElements[\"socialViewTab\"].buttons[\"person.badge.plus\"]",".buttons[\"person.badge.plus\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(addFriendButton.exists)
        addFriendButton.tap()
        //waiting for functionality
    }
    
    func testAcceptFriendRequest() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let navSocial = app.tabBars["Tab Bar"].buttons["person.2.fill"]
        XCTAssertTrue(navSocial.exists)
        navSocial.tap()
        
        // Temp waiting for Auth
        let loginButton = app/*@START_MENU_TOKEN@*/.buttons["loginButton"]/*[[".otherElements[\"socialViewTab\"]",".buttons[\"Log In\"]",".buttons[\"loginButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        let friendSection = app/*@START_MENU_TOKEN@*/.buttons["Friends"]/*[[".otherElements[\"socialViewTab\"]",".segmentedControls[\"logsFriendsTabPicker\"].buttons[\"Friends\"]",".buttons[\"Friends\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(friendSection.exists)
        friendSection.tap()
        
        
        let addFriendButton = app/*@START_MENU_TOKEN@*/.buttons["person.badge.plus"]/*[[".otherElements[\"socialViewTab\"].buttons[\"person.badge.plus\"]",".buttons[\"person.badge.plus\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(addFriendButton.exists)
        addFriendButton.tap()
        
        
        //waiting for functionality
        
        let acceptFriendRequestButton = app/*@START_MENU_TOKEN@*/.scrollViews/*[[".otherElements[\"socialViewTab\"].scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .button).matching(identifier: "Selected").element(boundBy: 0)
        XCTAssertTrue(acceptFriendRequestButton.exists)
        acceptFriendRequestButton.tap()
                
        
    }
    
    func testDeclineFriendRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        let navSocial = app.tabBars["Tab Bar"].buttons["person.2.fill"]
        XCTAssertTrue(navSocial.exists)
        navSocial.tap()
        
        // Temp waiting for Auth
        let loginButton = app/*@START_MENU_TOKEN@*/.buttons["loginButton"]/*[[".otherElements[\"socialViewTab\"]",".buttons[\"Log In\"]",".buttons[\"loginButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        let friendSection = app/*@START_MENU_TOKEN@*/.buttons["Friends"]/*[[".otherElements[\"socialViewTab\"]",".segmentedControls[\"logsFriendsTabPicker\"].buttons[\"Friends\"]",".buttons[\"Friends\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(friendSection.exists)
        friendSection.tap()
        
        
        let addFriendButton = app/*@START_MENU_TOKEN@*/.buttons["person.badge.plus"]/*[[".otherElements[\"socialViewTab\"].buttons[\"person.badge.plus\"]",".buttons[\"person.badge.plus\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(addFriendButton.exists)
        addFriendButton.tap()
        
        
        //waiting for functionality
        
        let removeFriendRequestButton = app/*@START_MENU_TOKEN@*/.scrollViews/*[[".otherElements[\"socialViewTab\"].scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other).element(boundBy: 0).children(matching: .other).element/*@START_MENU_TOKEN@*/.children(matching: .button).matching(identifier: "Remove Friend Request").element(boundBy: 0)/*[[".children(matching: .button).matching(identifier: \"Close\").element(boundBy: 0)",".children(matching: .button).matching(identifier: \"Remove Friend Request\").element(boundBy: 0)"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(removeFriendRequestButton.exists)
        removeFriendRequestButton.tap()
        
    }
    
    func testAcceptLogRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        let navSocial = app.tabBars["Tab Bar"].buttons["person.2.fill"]
        XCTAssertTrue(navSocial.exists)
        navSocial.tap()
        
        // Temp waiting for Auth
        let loginButton = app/*@START_MENU_TOKEN@*/.buttons["loginButton"]/*[[".otherElements[\"socialViewTab\"]",".buttons[\"Log In\"]",".buttons[\"loginButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        let friendSection = app/*@START_MENU_TOKEN@*/.buttons["Friends"]/*[[".otherElements[\"socialViewTab\"]",".segmentedControls[\"logsFriendsTabPicker\"].buttons[\"Friends\"]",".buttons[\"Friends\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(friendSection.exists)
        friendSection.tap()
        
        
        let addFriendButton = app/*@START_MENU_TOKEN@*/.buttons["person.badge.plus"]/*[[".otherElements[\"socialViewTab\"].buttons[\"person.badge.plus\"]",".buttons[\"person.badge.plus\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(addFriendButton.exists)
        addFriendButton.tap()
        
        
        //waiting for functionality
        
        
        let acceptLogRequestButton = app/*@START_MENU_TOKEN@*/.scrollViews/*[[".otherElements[\"socialViewTab\"].scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other).element(boundBy: 0).children(matching: .other).element/*@START_MENU_TOKEN@*/.children(matching: .button).matching(identifier: "Accept Log Request").element(boundBy: 0)/*[[".children(matching: .button).matching(identifier: \"Selected\").element(boundBy: 4)",".children(matching: .button).matching(identifier: \"Accept Log Request\").element(boundBy: 0)"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(acceptLogRequestButton.exists)
        acceptLogRequestButton.tap()
         
    }
    
    func testDeclineLogRequest() throws {
        let app = XCUIApplication()
        app.launch()
        
        let navSocial = app.tabBars["Tab Bar"].buttons["person.2.fill"]
        XCTAssertTrue(navSocial.exists)
        navSocial.tap()
        
        // Temp waiting for Auth
        let loginButton = app/*@START_MENU_TOKEN@*/.buttons["loginButton"]/*[[".otherElements[\"socialViewTab\"]",".buttons[\"Log In\"]",".buttons[\"loginButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        let friendSection = app/*@START_MENU_TOKEN@*/.buttons["Friends"]/*[[".otherElements[\"socialViewTab\"]",".segmentedControls[\"logsFriendsTabPicker\"].buttons[\"Friends\"]",".buttons[\"Friends\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(friendSection.exists)
        friendSection.tap()
        
        
        let addFriendButton = app/*@START_MENU_TOKEN@*/.buttons["person.badge.plus"]/*[[".otherElements[\"socialViewTab\"].buttons[\"person.badge.plus\"]",".buttons[\"person.badge.plus\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(addFriendButton.exists)
        addFriendButton.tap()
        
        
        //waiting for functionality
        
        
        let removeLogRequestButton = app/*@START_MENU_TOKEN@*/.scrollViews/*[[".otherElements[\"socialViewTab\"].scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other).element(boundBy: 0).children(matching: .other).element/*@START_MENU_TOKEN@*/.children(matching: .button).matching(identifier: "Remove Log Request").element(boundBy: 0)/*[[".children(matching: .button).matching(identifier: \"Close\").element(boundBy: 4)",".children(matching: .button).matching(identifier: \"Remove Log Request\").element(boundBy: 0)"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(removeLogRequestButton.exists)
        removeLogRequestButton.tap()
                
    }
}
