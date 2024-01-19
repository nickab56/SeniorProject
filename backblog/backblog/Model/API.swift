//
//  API.swift
//  backblog
//
//  Created by Nick Abegg on 1/19/24.
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

    enum NetworkError: Error {
        case invalidURL
        case noData
    }
}
