//
//  MovieDataTests.swift
//  backblogTests
//
//  Created by Jake Buhite on 2/18/24.
//

import XCTest
@testable import backblog

class MovieDataTests: XCTestCase {

    func testEquality() {
        let data1 = MovieData(adult: false, backdropPath: "/backdrop.jpg", belongsToCollection: nil, budget: 1000000, genres: nil, homepage: "www.example.com", id: 1, imdbId: "tt1234567", originalLanguage: "en", originalTitle: "Original Title", overview: "Overview", popularity: 123.45, posterPath: "/poster.jpg", productionCompanies: nil, productionCountries: nil, releaseDate: "2024-01-21", revenue: 5000000, runtime: 120, spokenLanguages: nil, status: "Released", tagline: "Tagline", title: "Title", video: false, voteAverage: 7.5, voteCount: 1000, images: nil, releaseDates: nil, watchProviders: nil, credits: nil)
        let data2 = MovieData(adult: false, backdropPath: "/backdrop.jpg", belongsToCollection: nil, budget: 1000000, genres: nil, homepage: "www.example.com", id: 1, imdbId: "tt1234567", originalLanguage: "en", originalTitle: "Original Title", overview: "Overview", popularity: 123.45, posterPath: "/poster.jpg", productionCompanies: nil, productionCountries: nil, releaseDate: "2024-01-21", revenue: 5000000, runtime: 120, spokenLanguages: nil, status: "Released", tagline: "Tagline", title: "Title", video: false, voteAverage: 7.5, voteCount: 1000, images: nil, releaseDates: nil, watchProviders: nil, credits: nil)
        
        XCTAssertEqual(data1, data2)
    }
    
    func testHashable() {
        let data = MovieData(adult: false, backdropPath: "/backdrop.jpg", belongsToCollection: nil, budget: 1000000, genres: nil, homepage: "www.example.com", id: 1, imdbId: "tt1234567", originalLanguage: "en", originalTitle: "Original Title", overview: "Overview", popularity: 123.45, posterPath: "/poster.jpg", productionCompanies: nil, productionCountries: nil, releaseDate: "2024-01-21", revenue: 5000000, runtime: 120, spokenLanguages: nil, status: "Released", tagline: "Tagline", title: "Title", video: false, voteAverage: 7.5, voteCount: 1000, images: nil, releaseDates: nil, watchProviders: nil, credits: nil)
        
        var hasher = Hasher()
        data.hash(into: &hasher)
        let hashedValue = hasher.finalize()
        XCTAssertNotNil(hashedValue)
    }
    
    func testCodable() {
        let data = MovieData(adult: false, backdropPath: "/backdrop.jpg", belongsToCollection: nil, budget: 1000000, genres: nil, homepage: "www.example.com", id: 1, imdbId: "tt1234567", originalLanguage: "en", originalTitle: "Original Title", overview: "Overview", popularity: 123.45, posterPath: "/poster.jpg", productionCompanies: nil, productionCountries: nil, releaseDate: "2024-01-21", revenue: 5000000, runtime: 120, spokenLanguages: nil, status: "Released", tagline: "Tagline", title: "Title", video: false, voteAverage: 7.5, voteCount: 1000, images: nil, releaseDates: nil, watchProviders: nil, credits: nil)
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            let decodedData = try JSONDecoder().decode(MovieData.self, from: jsonData)
            XCTAssertEqual(data, decodedData)
        } catch {
            XCTFail("Failed to code MovieData: \(error)")
        }
    }
}
