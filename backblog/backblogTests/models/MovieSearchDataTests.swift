//
//  MovieSearchDataTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class MovieSearchDataTests: XCTestCase {

    func testCodable() {
        let data = MovieSearchData(page: 1, results: [MovieSearchData.MovieSearchResult](), totalPages: 10, totalResults: 100)
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            let decodedData = try JSONDecoder().decode(MovieSearchData.self, from: jsonData)
            XCTAssertEqual(data, decodedData)
        } catch {
            XCTFail("Failed to encode or decode MovieSearchData: \(error)")
        }
    }
    
    func testMovieSearchResultEquality() {
        let result1 = MovieSearchData.MovieSearchResult(adult: false, backdropPath: "path1", genreIds: [1, 2], id: 123, originalLanguage: "en", originalTitle: "Title", overview: "Overview", popularity: 4.5, posterPath: "poster1", releaseDate: "2024-01-01", title: "Title", video: true, voteAverage: 4.0, voteCount: 100)
        let result2 = MovieSearchData.MovieSearchResult(adult: false, backdropPath: "path1", genreIds: [1, 2], id: 123, originalLanguage: "en", originalTitle: "Title", overview: "Overview", popularity: 4.5, posterPath: "poster1", releaseDate: "2024-01-01", title: "Title", video: true, voteAverage: 4.0, voteCount: 100)
        
        XCTAssertEqual(result1, result2)
    }
}
