//
//  LogsViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 04/04/24.
//

import XCTest
@testable import backblog
import CoreData

class LogsViewModelTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var mockMSSuccced: MockMovieService!
    var logsVMSucceed: LogsViewModel!
    
    var mockFBError: MockFirebaseService!
    var mockMSError: MockMovieService!
    var logsVMError: LogsViewModel!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        
        mockMSSuccced = MockMovieService()
        mockMSError = MockMovieService()
        mockMSError.shouldSucceed = false
        
        logsVMSucceed = LogsViewModel(fb: mockFBSucceed, movieService: mockMSSuccced)
        logsVMError = LogsViewModel(fb: mockFBError, movieService: mockMSError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        logsVMSucceed = nil
        mockMSSuccced = nil
        mockFBError = nil
        logsVMError = nil
        mockMSError = nil
        super.tearDown()
    }
    
    func testAddLogSuccess() {
        let name = "My Log"
        let isVisible = false
        let collaborators: [String] = ["mockUserId"]
        logsVMSucceed.addLog(name: name, isVisible: isVisible, collaborators: collaborators)
    }
    
    func testAddLogNilUserId() {
        let name = "My Log"
        let isVisible = false
        let collaborators: [String] = ["mockUserId"]
        mockFBSucceed.validUserId = false
        logsVMSucceed.addLog(name: name, isVisible: isVisible, collaborators: collaborators)
    }
    
    func testAddLogException() {
        let name = "My Log"
        let isVisible = false
        let collaborators: [String] = ["mockUserId"]
        logsVMError.addLog(name: name, isVisible: isVisible, collaborators: collaborators)
    }
    
    func testFetchLogsSuccess() {
        logsVMSucceed.fetchLogs()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                !self.logsVMSucceed.logs.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testFetchLogsException() {
        logsVMError.fetchLogs()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMSucceed.logs.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testFetchLogsLocalSuccess() {
        addNewLocalLog()
        mockFBSucceed.validUserId = false
        logsVMSucceed.fetchLogs()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                !self.logsVMSucceed.logs.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 10)
        resetAllLogs()
    }
    
    func testGetFriendsSuccess() {
        logsVMSucceed.getFriends()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                !self.logsVMSucceed.friends.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetFriendsNilUserId() {
        mockFBSucceed.validUserId = false
        logsVMSucceed.getFriends()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMSucceed.friends.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testGetFriendsException() {
        logsVMError.getFriends()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMError.friends.isEmpty
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testRefreshPriorityLog() {
        // No logs
        logsVMSucceed.refreshPriorityLog()
        
        // Now has logs
        logsVMSucceed.refreshPriorityLog()
    }
    
    func testGetUserId() {
        let result = logsVMSucceed.getUserId()
        XCTAssert(result == "mockUserId")
        
        mockFBSucceed.validUserId = false
        let result1 = logsVMSucceed.getUserId()
        XCTAssertNil(result1)
    }
    
    func testUpdateLogsOrderSuccess() {
        let ownerData = Owner(userId: "mockUserId", priority: 0)
        let logData = [LogData(logId: "log123", name: "My Log", creationDate: "old", lastModifiedDate: "now", isVisible: true, owner: ownerData, movieIds: ["11"], watchedIds: [], collaborators: [], order: [:]), LogData(logId: nil, name: "My Second Log", creationDate: "oldish", lastModifiedDate: "now", isVisible: false, owner: ownerData, movieIds: [], watchedIds: [], collaborators: [], order: [:])]
        logsVMSucceed.updateLogsOrder(logs: logData)
    }
    
    func testUpdateLogsOrderNilUserId() {
        let ownerData = Owner(userId: "mockUserId", priority: 0)
        let logData = [LogData(logId: "log123", name: "My Log", creationDate: "old", lastModifiedDate: "now", isVisible: true, owner: ownerData, movieIds: ["11"], watchedIds: [], collaborators: [], order: [:]), LogData(logId: "log456", name: "My Second Log", creationDate: "oldish", lastModifiedDate: "now", isVisible: false, owner: ownerData, movieIds: [], watchedIds: [], collaborators: [], order: [:])]
        mockFBSucceed.validUserId = false
        logsVMSucceed.updateLogsOrder(logs: logData)
    }
    
    func testUpdateLogsOrderException() {
        let ownerData = Owner(userId: "mockUserId", priority: 0)
        let logData = [LogData(logId: "log123", name: "My Log", creationDate: "old", lastModifiedDate: "now", isVisible: true, owner: ownerData, movieIds: ["11"], watchedIds: [], collaborators: [], order: [:]), LogData(logId: "log456", name: "My Second Log", creationDate: "oldish", lastModifiedDate: "now", isVisible: false, owner: ownerData, movieIds: [], watchedIds: [], collaborators: [], order: [:])]
        logsVMError.updateLogsOrder(logs: logData)
    }
    
    func testMarkMovieAsWatchedSuccess() {
        let movieId = "11"
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        
        logsVMSucceed.nextMovie = movieId
        logsVMSucceed.markMovieAsWatched(log: LogType.log(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMSucceed.showingWhatsNextCompleteNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testMarkMovieAsWatchedNotFoundInMovies() {
        let movieId = "11"
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        
        logsVMSucceed.nextMovie = movieId
        logsVMSucceed.markMovieAsWatched(log: LogType.log(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMSucceed.showingWhatsNextCompleteNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testMarkMovieAsWatchedNilLogId() {
        let movieId = "11"
        let log = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        
        logsVMSucceed.nextMovie = movieId
        logsVMSucceed.markMovieAsWatched(log: LogType.log(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMSucceed.showingWhatsNextCompleteNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testMarkMovieAsWatchedError() {
        let movieId = "11"
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        
        logsVMError.nextMovie = movieId
        logsVMError.markMovieAsWatched(log: LogType.log(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMError.showingWhatsNextCompleteNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testMarkMovieAsWatchedLocalSuccess() {
        // Test log data
        let context = PersistenceController.shared.container.viewContext
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        // Fake movie data
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "12"
        movieData.movie_index = 0
        
        log.addToMovie_ids(movieData)
        
        logsVMSucceed.nextMovie = "12"
        logsVMSucceed.markMovieAsWatched(log: LogType.localLog(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMSucceed.showingWhatsNextCompleteNotification == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
        
        resetAllLogs()
    }
    
    func testMarkMovieAsWatchedLocalNextMovieNotFound() {
        // Test log data
        let context = PersistenceController.shared.container.viewContext
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        // Fake movie data
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        log.addToMovie_ids(movieData)
        
        logsVMSucceed.nextMovie = "12"
        logsVMSucceed.markMovieAsWatched(log: LogType.localLog(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMSucceed.showingWhatsNextCompleteNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
        
        resetAllLogs()
    }
    
    func testMarkMovieAsWatchedLocalNotFoundInMovieIds() {
        // Test log data
        let context = PersistenceController.shared.container.viewContext
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        logsVMSucceed.markMovieAsWatched(log: LogType.localLog(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.logsVMSucceed.showingWhatsNextCompleteNotification == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
        
        resetAllLogs()
    }
    
    private func addNewLocalLog() {
        let viewContext = PersistenceController.shared.container.viewContext
        let newLog = LocalLogData(context: viewContext)
        newLog.name = "My Log"
        newLog.log_id = Int64(UUID().hashValue)
        
        let movieData = LocalMovieData(context: viewContext)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        let movieData2 = LocalMovieData(context: viewContext)
        movieData2.movie_id = "131"
        movieData2.movie_index = 1
        
        newLog.addToMovie_ids(movieData)
        newLog.addToMovie_ids(movieData2)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func resetAllLogs() {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
    }
}
