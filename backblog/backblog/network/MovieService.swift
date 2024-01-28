//
//  MovieService.swift
//  backblog
//
//  Created by Jake Buhite on 1/26/24.
//

import Foundation

struct MovieService {
    static let shared = MovieService()
    let baseURL = "https://api.themoviedb.org/3/"
   
    enum MovieError: Error {
        case networkError
        case decodingError
    }
   
    func searchMovie(query: String, includeAdult: Bool, language: String, page: Int) async -> Result<MovieSearchData, Error> {
        let endpointExt = "search/movie?query=\(query)&include_adult=\(includeAdult)&language=\(language)&page=\(page)"
        let url = URL(string: baseURL + endpointExt)!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(MovieAccess.shared.MOVIE_SECRET)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let searchResults = try? JSONDecoder().decode(MovieSearchData.self, from: data) {
                return .success(searchResults)
            } else {
                return .failure(MovieError.decodingError)
            }
        } catch {
            return .failure(error)
        }
    }
   
     func getMovieByID(movieId: String) async -> Result<MovieData, Error> {
         let endpointExt = "movie/\(movieId)?append_to_response=images,release_dates,watch/providers,credits"
         let url = URL(string: baseURL + endpointExt)!
         
         var request = URLRequest(url: url)
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.setValue("Bearer \(MovieAccess.shared.MOVIE_SECRET)", forHTTPHeaderField: "Authorization")
         
         do {
             let (data, _) = try await URLSession.shared.data(for: request)
             if let searchResults = try? JSONDecoder().decode(MovieData.self, from: data) {
                 return .success(searchResults)
             } else {
                 return .failure(MovieError.decodingError)
             }
         } catch {
             return .failure(error)
         }
    }
}
