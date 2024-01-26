//
//  MovieSearchData.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import Foundation

class MovieSearchData: Codable {
    var page: Int?
    var results: [MovieSearchResult]?
    var totalPages: Int?
    var totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    class MovieSearchResult: Codable {
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
