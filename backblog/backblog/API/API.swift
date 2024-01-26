//
//  API.swift
//  backblog
//
//  Created by Nick Abegg on 1/19/24.
//
//

import Foundation

struct Wrapper: Codable {
    let data: MovieResponse
}

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
}

// remove no half-sheet, no backdrop
// sort highest popularity
struct Movie: Codable, Identifiable {
    let id: Int
    let adult: Bool
    let backdrop_path: String?
    let half_sheet: String?
    let genre_ids: [Int]
    let original_language: String
    let original_title: String
    let overview: String
    let popularity: Double
    let poster_path: String?
    let release_date: String
    let title: String
    let video: Bool
    let vote_average: Double
    let vote_count: Int
}

struct MovieDetailResponse: Codable {
    let data: MovieDetail
}

struct MovieDetail: Codable, Identifiable {
    let id: Int
    let adult: Bool
    let backdropPath: String?
    let budget: Int?
    let genres: [Genre]
    let homepage: String?
    let imdbId: String?
    let originalLanguage: String?
    let originalTitle: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let releaseDate: String?
    let revenue: Int?
    let runtime: Int?
    let spokenLanguages: [SpokenLanguage]
    let status: String?
    let tagline: String?
    let title: String
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, adult, budget, genres, homepage, overview, popularity, status, tagline, title, video
        case backdropPath = "backdrop_path"
        case imdbId = "imdb_id"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case revenue, runtime
        case spokenLanguages = "spoken_languages"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct ProductionCompany: Codable {
    let id: Int
    let logoPath: String?
    let name: String
    let originCountry: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}

struct ProductionCountry: Codable {
    let iso3166_1: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}

struct SpokenLanguage: Codable {
    let iso639_1: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case name
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func fetchMovies(searchQuery: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-backblog.cloudfunctions.net/searchMovie") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["query": searchQuery]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                // Decode the Wrapper struct first
                let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
                // Extract the MovieResponse and then its results
                let movies = wrapper.data.results
                completion(.success(movies))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    
    func fetchMovieById(_ id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-backblog.cloudfunctions.net/getMovieById") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Int] = ["movie_id": id]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let movieDetailResponse = try JSONDecoder().decode(MovieDetailResponse.self, from: data)
                let movieDetail = movieDetailResponse.data
                completion(.success(movieDetail))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }


        enum NetworkError: Error {
            case invalidURL
            case noData
            case invalidData
        }
}
