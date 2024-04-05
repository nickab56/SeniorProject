//
//  MoviesViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/21/24.
//

import XCTest
import CoreData
@testable import backblog

class MoviesViewModelTests: XCTestCase {
    var mockFBSucceed: MockFirebaseService!
    var mockMSSuccced: MockMovieService!
    var moviesViewModelSucceed: MoviesViewModel!
    
    var mockFBError: MockFirebaseService!
    var mockMSError: MockMovieService!
    var moviesViewModelError: MoviesViewModel!
    
    override func setUp() {
        super.setUp()
        mockFBSucceed = MockFirebaseService()
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        
        mockMSSuccced = MockMovieService()
        mockMSError = MockMovieService()
        mockMSError.shouldSucceed = false
        
        let movieId = "11"
        let isComingFromLog = true
        let log: LogType? = nil
        moviesViewModelSucceed = MoviesViewModel(movieId: movieId, isComingFromLog: isComingFromLog, log: log, fb: mockFBSucceed, movieService: mockMSSuccced)
        moviesViewModelError = MoviesViewModel(movieId: movieId, isComingFromLog: isComingFromLog, log: log, fb: mockFBError, movieService: mockMSError)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        moviesViewModelSucceed = nil
        mockFBError = nil
        moviesViewModelError = nil
        super.tearDown()
    }
    
    func testInitializationSuccess() async {
        let isLoading = true
        let movieData: MovieData? = nil
        let errorMessage: String? = nil
        let movieId = "11"
        let isComingFromLog = true
        
        XCTAssertEqual(moviesViewModelSucceed.isLoading, isLoading)
        XCTAssertEqual(moviesViewModelSucceed.movieData, movieData)
        XCTAssertEqual(moviesViewModelSucceed.errorMessage, errorMessage)
        XCTAssertEqual(moviesViewModelSucceed.movieId, movieId)
        XCTAssertEqual(moviesViewModelSucceed.isComingFromLog, isComingFromLog)
    }
    
    func testFetchMovieDetailsSuccess() {
        moviesViewModelSucceed.fetchMovieDetails()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.moviesViewModelSucceed.movieData != nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testFetchMovieDetailsError() {
        moviesViewModelError.fetchMovieDetails()
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.moviesViewModelError.errorMessage != nil
            }), object: nil)
        wait(for: [expectation], timeout: 5)
        XCTAssertNil(moviesViewModelError.movieData)
        XCTAssertNotNil(moviesViewModelError.errorMessage)
    }
    
    func testCheckMovieStatusSuccess() {
        let log = LogData(logId: "log123", name: "My Log", creationDate: "now", lastModifiedDate: "now", isVisible: true, owner: Owner(userId: "mockUserId", priority: 1), movieIds: ["11", "12", "156"], watchedIds: ["1234", "13", "1"], collaborators: [], order: [:])
        
        moviesViewModelSucceed.log = LogType.log(log)
        moviesViewModelSucceed.checkMovieStatus()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.moviesViewModelSucceed.isInUnwatchedMovies == true &&
                self.moviesViewModelSucceed.isInWatchedMovies == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
    }
    
    func testCheckMovieStatusLocalSuccess() {
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
        
        moviesViewModelSucceed.log = LogType.localLog(log)
        moviesViewModelSucceed.checkMovieStatus()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(block: { _, _ in
                self.moviesViewModelSucceed.isInUnwatchedMovies == true &&
                self.moviesViewModelSucceed.isInWatchedMovies == false
            }), object: nil)
        wait(for: [expectation], timeout: 5)
        
        resetAllLogs()
    }
    
    func testMoveMovieToWatched() {
        moviesViewModelSucceed.moveMovieToWatched()
    }
    
    func testMoveMovieToUnwatched() {
        moviesViewModelSucceed.moveMovieToUnwatched()
    }
    
    func testFormatReleaseYearSuccess() {
        let date = "2024-03-11"
        let year = "2024"
        let result = moviesViewModelSucceed.formatReleaseYear(from: date)
        XCTAssertEqual(result, year)
    }
    
    func testFormatReleaseYearError() {
        let date = ""
        let year = "Unknown year"
        let result = moviesViewModelSucceed.formatReleaseYear(from: date)
        XCTAssertEqual(result, year)
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
