//
//  MovieData.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//  Updated by Jake Buhite on 2/23/24.
//
//  Description: Represents the data model for a movie response from TMDB.
//

import Foundation

/// Represents the data model for a movie response from TMDB.
struct MovieData: Hashable, Codable {
    static func == (lhs: MovieData, rhs: MovieData) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var adult: Bool?
    var backdropPath: String?
    var belongsToCollection: Collection?
    var budget: Int?
    var genres: [Genre]?
    var homepage: String?
    var id: Int?
    var imdbId: String?
    var originalLanguage: String?
    var originalTitle: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var productionCompanies: [ProductionCompany]?
    var productionCountries: [Dictionary<String, String?>]?
    var releaseDate: String?
    var revenue: Int?
    var runtime: Int?
    var spokenLanguages: [Dictionary<String, String?>]?
    var status: String?
    var tagline: String?
    var title: String?
    var video: Bool?
    var voteAverage: Double?
    var voteCount: Int?
    var images: MovieImages?
    var releaseDates: ReleaseDates?
    var watchProviders: WatchProviders?
    var credits: Credits?
    
    enum CodingKeys: String, CodingKey {
        case adult, budget, genres, homepage, id, overview, popularity, revenue, runtime, status, tagline, title, video, images, credits
        case backdropPath = "backdrop_path"
        case belongsToCollection = "belongs_to_collection"
        case imdbId = "imdb_id"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case spokenLanguages = "spoke_languages"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case releaseDates = "release_dates"
        case watchProviders = "watch_providers"
    }
    
    /// Represents a collection that a movie may belong to.
    struct Collection: Codable {
        var id: Int?
        var name: String?
        var posterPath: String?
        var backdropPath: String?
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case posterPath = "poster_path"
            case backdropPath = "backdrop_path"
        }
    }
    
    /// Represents a genre of a movie.
    struct Genre: Codable {
        var id: Int?
        var name: String?
    }
    
    /// Represents a production company associatedd with a movie.
    struct ProductionCompany: Codable {
        var id: Int?
        var logoPath: String?
        var name: String?
        var originCountry: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case logoPath = "logo_path"
            case name
            case originCountry = "origin_country"
        }
    }
    
    /// Represents images related to a movie.
    struct MovieImages: Codable {
        var backdrops: [Image]?
        var logos: [Image]?
        var posters: [Image]?
        
        struct Image: Codable {
            var aspectRatio: Double?
            var height: Int?
            var iso6391: String?
            var filePath: String?
            var voteAverage: Double?
            var voteCount: Int?
            var width: Int?
            
            enum CodingKeys: String, CodingKey {
                case height, width
                case aspectRatio = "aspect_ratio"
                case iso6391 = "iso_639_1"
                case filePath = "file_path"
                case voteAverage = "vote_average"
                case voteCount = "vote_count"
            }
        }
    }
    
    /// Represents release dates of a movie.
    struct ReleaseDates: Codable {
        var results: [ReleaseDate]?
        
        struct ReleaseDate: Codable {
            var iso31661: String?
            var releaseDates: [ReleaseDateItem]?
            
            enum CodingKeys: String, CodingKey {
                case iso31661 = "iso_3166_1"
                case releaseDates = "release_dates"
            }
            
            struct ReleaseDateItem: Codable {
                var certification: String?
                var descriptors: [String?]?
                var iso6391: String?
                var note: String?
                var releaseDate: String?
                var type: Int
                
                enum CodingKeys: String, CodingKey {
                    case certification, descriptors, note, type
                    case iso6391 = "iso_639_1"
                    case releaseDate = "release_date"
                }
            }
        }
    }
    
    /// Represents watch providers of a movie.
    struct WatchProviders: Codable {
        var results: Dictionary<String?, WatchProviderResults>?
        
        struct WatchProviderResults: Codable {
            var link: String
            var flatrate: [Flatrate]?
            
            struct Flatrate: Codable {
                var logoPath: String?
                var providerId: Int?
                var providerName: String?
                var displayPriority: Int?
                
                enum CodingKeys: String, CodingKey {
                    case logoPath = "logo_path"
                    case providerId = "provider_id"
                    case providerName = "provider_name"
                    case displayPriority = "display_priority"
                }
            }
        }
    }
    
    /// Represents the credits of a movie, including cast and crew.
    struct Credits: Codable {
        var cast: [Cast]?
        var crew: [Crew]?
        
        struct Cast: Codable {
            var adult: Bool?
            var gender: Int?
            var id: Int?
            var knownForDepartment: String?
            var name: String?
            var originalName: String?
            var popularity: Double?
            var profilePath: String?
            var castId: Int?
            var character: String?
            var creditId: String?
            var order: Int?
            
            enum CodingKeys: String, CodingKey {
                case adult, gender, id, name, popularity, character, order
                case knownForDepartment = "known_for_department"
                case originalName = "original_name"
                case profilePath = "profile_path"
                case castId = "cast_id"
                case creditId = "credit_id"
            }
        }
        
        struct Crew: Codable {
            var adult: Bool?
            var gender: Int?
            var id: Int?
            var knownForDepartment: String?
            var name: String?
            var originalName: String?
            var popularity: Double?
            var profilePath: String?
            var creditId: String?
            var department: String?
            var job: String?
            
            enum CodingKeys: String, CodingKey {
                case adult, gender, id, name, popularity, department, job
                case knownForDepartment = "known_for_department"
                case originalName = "original_name"
                case profilePath = "profile_path"
                case creditId = "credit_id"
            }
        }
    }
    
    
}
