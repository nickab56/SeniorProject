//
//  MovieRepositoryTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class MovieRepositoryTests: XCTestCase {
    var movieService: MovieService!
    
    var mockFBSucceed: MockFirebaseService!
    var movieRepoSucceed: MovieRepository!
    
    var mockFBError: MockFirebaseService!
    var movieRepoError: MovieRepository!
    
    override func setUp() {
        super.setUp()
        movieService = MovieService()
        
        mockFBSucceed = MockFirebaseService()
        movieRepoSucceed = MovieRepository(fb: mockFBSucceed, movieService: movieService)
        
        mockFBError = MockFirebaseService()
        mockFBError.shouldSucceed = false
        movieRepoError = MovieRepository(fb: mockFBError, movieService: movieService)
    }
    
    override func tearDown() {
        mockFBSucceed = nil
        movieRepoSucceed = nil
        mockFBError = nil
        movieRepoError = nil
        super.tearDown()
    }
    
    func testAddMovieSuccess() async {
        let logId = "log123"
        let movieId = "11"
        
        do {
            let result = try await movieRepoSucceed.addMovie(logId: logId, movieId: movieId).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testAddMovieThrowsError() async {
        let logId = "log123"
        let movieId = "11"
        
        do {
            _ = try await movieRepoError.addMovie(logId: logId, movieId: movieId).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testMarkMovieWatchedSuccess() async {
        let logId = "log123"
        let movieId = "11"
        let watched = true
        
        do {
            let result = try await movieRepoSucceed.markMovie(logId: logId, movieId: movieId, watched: watched).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testMarkMovieUnWatchedSuccess() async {
        let logId = "log123"
        let movieId = "11"
        let watched = false
        
        do {
            let result = try await movieRepoSucceed.markMovie(logId: logId, movieId: movieId, watched: watched).get()
            
            XCTAssert(result)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testMarkMovieThrowsError() async {
        let logId = "log123"
        let movieId = "11"
        let watched = true
        
        do {
            _ = try await movieRepoError.markMovie(logId: logId, movieId: movieId, watched: watched).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testGetWatchNextMovieSuccess() async {
        let userId = "mockUserId"
        
        do {
            let result = try await movieRepoSucceed.getWatchNextMovie(userId: userId).get()
            
            XCTAssertEqual(result, "11")
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetWatchNextMovieThrowsError() async {
        let userId = "mockUserId"
        
        do {
            _ = try await movieRepoError.getWatchNextMovie(userId: userId).get()
            XCTFail("Function should not have returned successfully")
        } catch {
            XCTAssert(error.localizedDescription == "Mock error")
        }
    }
    
    func testSearchMovieSuccess() async {
        let query = "Star Wars"
        
        do {
            let result = try await movieRepoSucceed.searchMovie(query: query, page: 1).get()
            
            XCTAssertNotNil(result.results)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testSearchMovieThrowsError() async {
        let query = "Star Wars"
        
        do {
            let result = try await movieRepoSucceed.searchMovie(query: query, page: 1).get()
            
            XCTAssertNotNil(result.results)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetMovieByIdSuccess() async {
        let movieId = "11"
        
        do {
            let result = try await movieRepoSucceed.getMovieById(movieId: movieId).get()
            
            XCTAssertEqual(String(result.id ?? -1), movieId)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetMovieHalfSheetSuccess() async {
        let movieId = "11"
        let backdropPath = "/wTyRLd775smT4kEym0zN7GgZ6hq.jpg"
        
        do {
            let result = try await movieRepoSucceed.getMovieHalfSheet(movieId: movieId).get()
            
            XCTAssertEqual(result, backdropPath)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testGetMoviePosterSuccess() async {
        let movieId = "11"
        let posterPath = "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg"
        
        do {
            let result = try await movieRepoSucceed.getMoviePoster(movieId: movieId).get()
            
            XCTAssertEqual(result, posterPath)
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    
    
    // TODO: Implement tests for error handling for the following functions
    // searchMovie
    // getMovieById
    // getMovieHalfSheet
    // getMoviePoster
}
