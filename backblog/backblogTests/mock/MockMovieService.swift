//
//  MockMovieService.swift
//  backblogTests
//
//  Created by Jake Buhite on 3/21/24.
//

import Firebase
import FirebaseFirestoreSwift
@testable import backblog

class MockMovieService: MovieProtocol {
    var shouldSucceed = true // Flag to control success/failure of methods
    
    let baseURL = "https://api.themoviedb.org/3/"
   
    enum MovieError: Error {
        case networkError
        case decodingError
        case emptyFieldError
    }
   
    func searchMovie(query: String, includeAdult: Bool, language: String, page: Int) async -> Result<MovieSearchData, Error> {
        if (shouldSucceed) {
            let testResult = MovieSearchData(
                page: 1,
                results: [],
                totalPages: 1,
                totalResults: 10
            )
            return .success(testResult)
        }
        return .failure(MovieError.networkError)
    }
   
     func getMovieByID(movieId: String) async -> Result<MovieData, Error> {
         if (shouldSucceed) {
             let testResult = MovieData(
                adult: false,
                backdropPath: nil,
                belongsToCollection: nil,
                budget: nil,
                genres: nil,
                homepage: nil,
                id: 11,
                imdbId: nil,
                originalLanguage: nil,
                originalTitle: nil,
                overview: nil,
                popularity: nil,
                posterPath: nil,
                productionCompanies: nil,
                productionCountries: nil,
                releaseDate: nil,
                revenue: 1234,
                runtime: 123,
                spokenLanguages: nil,
                status: nil,
                tagline: nil,
                title: "Test Movie",
                video: nil,
                voteAverage: nil,
                voteCount: nil,
                images: nil,
                releaseDates: nil,
                watchProviders: nil,
                credits: nil
             )
             return .success(testResult)
         }
         return .failure(MovieError.networkError)
    }
    
    func getMovieHalfSheet(movieId: String) async -> Result<String, Error> {
        if (shouldSucceed) {
            let testResult = "backdrop.png"
            return .success(testResult)
        }
        return .failure(MovieError.networkError)
    }
    
    func getMoviePoster(movieId: String) async -> Result<String, Error> {
        if (shouldSucceed) {
            let testResult = "poster.png"
            return .success(testResult)
        }
        return .failure(MovieError.networkError)
    }
}

