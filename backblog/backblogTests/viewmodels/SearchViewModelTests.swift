//
//  SearchViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/25/24.
//

import XCTest
@testable import backblog
import CoreData

class SearchViewModelTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var mockMSSuccced: MockMovieService!
    var searchVMSucceed: SearchViewModel!
    
    var mockFBError: MockFirebaseService!
    var mockMSError: MockMovieService!
    var searchVMError: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        
        mockMSSuccced = MockMovieService()
        mockMSError = MockMovieService()
        mockMSError.shouldSucceed = false
        
        searchVMSucceed = SearchViewModel(fb: mockFBSucceed, movieService: mockMSSuccced)
        searchVMError = SearchViewModel(fb: mockFBError, movieService: mockMSError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        searchVMSucceed = nil
        mockMSSuccced = nil
        mockFBError = nil
        searchVMError = nil
        mockMSError = nil
        super.tearDown()
    }

    func testFormatReleaseYearSuccess() {
        let date = "2024-03-11"
        let year = "2024"
        let result = searchVMSucceed.formatReleaseYear(from: date)
        XCTAssertEqual(result, year)
    }
    
    func testFormatReleaseYearError() {
        let date = ""
        let year = "Unknown year"
        let result = searchVMSucceed.formatReleaseYear(from: date)
        XCTAssertEqual(result, year)
    }
    
    func testSearchMoviesSuccessful() {
        searchVMSucceed.searchMovies(query: "Star Wars")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMSucceed.movies == []
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testSearchMoviesEmptyQuery() {
        searchVMSucceed.searchMovies(query: "")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMSucceed.movies == []
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testSearchMoviesError() {
        searchVMError.searchMovies(query: "Star Wars")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMError.errorMessage != nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSearchMoviesByGenreSuccessful() {
        searchVMSucceed.searchMoviesByGenre(genreId: "38")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMSucceed.movies == []
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testSearchMoviesByGenreError() {
        searchVMError.searchMoviesByGenre(genreId: "38")
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMError.errorMessage != nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testLoadHalfSheetPathSuccessful() {
        let movieId = 11
        searchVMSucceed.loadHalfSheetImage(movieId: movieId)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMSucceed.halfSheetImageUrls[movieId] != nil
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testLoadHalfSheetPathEmpty() {
        let movieId = 11
        mockMSSuccced.emptyHalfSheet = true
        searchVMSucceed.loadHalfSheetImage(movieId: movieId)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMSucceed.halfSheetImageUrls[movieId] == nil
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testLoadHalfSheetPathError() {
        let movieId = 11
        searchVMError.loadHalfSheetImage(movieId: movieId)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMError.halfSheetImageUrls[movieId] == nil
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testLoadBackdropImageSuccessful() {
        let movieId = 11
        searchVMSucceed.loadBackdropImage(movieId: movieId)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMSucceed.backdropImageUrls[movieId] != nil
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testLoadBackdropImageEmpty() {
        let movieId = 11
        mockMSSuccced.emptyHalfSheet = true
        searchVMSucceed.loadBackdropImage(movieId: movieId)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMSucceed.backdropImageUrls[movieId] == nil
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testLoadBackdropImageError() {
        let movieId = 11
        searchVMError.loadBackdropImage(movieId: movieId)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.searchVMError.backdropImageUrls[movieId] == nil
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testAddMovieToLogSuccessful() {
        let logData = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: nil, movieIds: [], watchedIds: ["11"], collaborators: [], order: [:])
        let log = LogType.log(logData)
        let movieId = "11"
        
        searchVMSucceed.addMovieToLog(movieId: movieId, log: log)
    }
    
    func testAddMovieToLogNullLogId() {
        let logData = LogData(logId: nil, name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: nil, movieIds: [], watchedIds: [], collaborators: [], order: [:])
        let log = LogType.log(logData)
        let movieId = "11"
        
        searchVMSucceed.addMovieToLog(movieId: movieId, log: log)
    }
    
    func testAddMovieToLogError() {
        let logData = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: nil, movieIds: ["11"], watchedIds: [], collaborators: [], order: [:])
        let log = LogType.log(logData)
        let movieId = "11"
        
        searchVMError.addMovieToLog(movieId: movieId, log: log)
    }
    
    func testAddMovieToLocalLogSuccessful() {
        // Add test log
        let context = PersistenceController.shared.container.viewContext
        let logData = LocalLogData(context: context)
        logData.log_id = 123
        logData.name = "My Log"
        logData.creation_date = "now"
        let log = LogType.localLog(logData)
        let movieId = "11"
        
        searchVMSucceed.addMovieToLog(movieId: movieId, log: log)
        
        resetAllLogs()
    }
    
    func testAddMovieToLocalLogInWatchedSuccessful() {
        // Add test log
        let context = PersistenceController.shared.container.viewContext
        let logData = LocalLogData(context: context)
        logData.log_id = 123
        logData.name = "My Log"
        logData.creation_date = "now"
        
        // Fake movie data
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        logData.addToWatched_ids(movieData)
        
        let log = LogType.localLog(logData)
        let movieId = "11"
        
        searchVMSucceed.addMovieToLog(movieId: movieId, log: log)
        
        resetAllLogs()
    }
    
    func testIsMovieNotInLogSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: nil, watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        
        let result = searchVMSucceed.isMovieInLog(movieId: "11", log: LogType.log(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testIsMovieInLogSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["11", "13", "1"], collaborators: [], order: [:])
        
        let result = searchVMSucceed.isMovieInLog(movieId: "11", log: LogType.log(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testIsMovieNotInLogLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        let result = searchVMSucceed.isMovieInLog(movieId: "11", log: LogType.localLog(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result == false
            }), object: nil)
        wait(for: [expectation], timeout: 10)
    }
    
    func testIsMovieInLogLocalSuccess() {
        let context = PersistenceController.shared.container.viewContext
        
        // Test log data
        let log = LocalLogData(context: context)
        log.log_id = 123
        log.name = "My Log"
        
        // Fake movie data
        let movieData = LocalMovieData(context: context)
        movieData.movie_id = "11"
        movieData.movie_index = 0
        
        log.addToMovie_ids(movieData)
        
        let result = searchVMSucceed.isMovieInLog(movieId: "11", log: LogType.localLog(log))
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                result == true
            }), object: nil)
        wait(for: [expectation], timeout: 10)
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



