//
//  MovieSearchData.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import Foundation

struct MovieSearchData: Codable, Equatable {
    static func == (lhs: MovieSearchData, rhs: MovieSearchData) -> Bool {
        return lhs.page == rhs.page &&
        lhs.totalPages == rhs.totalPages &&
        lhs.totalResults == rhs.totalResults &&
        lhs.results?.count == rhs.results?.count
    }
    
    var page: Int?
    var results: [MovieSearchResult]?
    var totalPages: Int?
    var totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    struct MovieSearchResult: Codable, Equatable {
        static func == (lhs: MovieSearchResult, rhs: MovieSearchResult) -> Bool {
            return lhs.id == rhs.id
        }
        
        var adult: Bool?
        var backdropPath: String?
        var genreIds: [Int]?
        var id: Int?
        var originalLanguage: String?
        var originalTitle: String?
        var overview: String?
        var popularity: Double?
        var posterPath: String?
        var releaseDate: String?
        var title: String?
        var video: Bool?
        var voteAverage: Double?
        var voteCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case adult, id, overview, popularity, title, video
            case backdropPath = "backdrop_path"
            case genreIds = "genre_ids"
            case originalLanguage = "original_language"
            case originalTitle = "original_title"
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
    }
}
