//
//  MoviesViewModelTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/21/24.
//

import XCTest
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
        let isInUnwatchlist = false
        
        XCTAssertEqual(moviesViewModelSucceed.isLoading, isLoading)
        XCTAssertEqual(moviesViewModelSucceed.movieData, movieData)
        XCTAssertEqual(moviesViewModelSucceed.errorMessage, errorMessage)
        XCTAssertEqual(moviesViewModelSucceed.movieId, movieId)
        XCTAssertEqual(moviesViewModelSucceed.isComingFromLog, isComingFromLog)
        XCTAssertEqual(moviesViewModelSucceed.isInUnwatchlist, isInUnwatchlist)
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
}
