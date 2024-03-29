//
//  MovieService.swift
//  backblog
//
//  Created by Jake Buhite on 1/26/24.
//

import Foundation

struct MovieService: MovieProtocol {
    let baseURL = "https://api.themoviedb.org/3/"
   
    enum MovieError: Error {
        case networkError
        case decodingError
        case emptyFieldError
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
    
    func getMovieHalfSheet(movieId: String) async -> Result<String, Error> {
        let endpointExt = "movie/\(movieId)/images"
        let url = URL(string: baseURL + endpointExt)!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(MovieAccess.shared.MOVIE_SECRET)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let imageResults = try? JSONDecoder().decode(MovieImageData.self, from: data) {
                if let backdrop = imageResults.backdrops?.first(where: { $0.iso6391 == "en" }) {
                    guard let halfsheet = backdrop.filePath else {
                        return .success("")
                    }
                    
                    return .success(halfsheet)
                }
                
                // No backdrop image from english language, check for others
                if (imageResults.backdrops == nil || imageResults.backdrops!.count == 0) {
                    return .success("")
                }
                
                guard let halfsheet = imageResults.backdrops?[0].filePath else {
                    return .success("")
                }
                
                return .success(halfsheet)
            } else {
                return .failure(MovieError.decodingError)
            }
        } catch {
            return .failure(error)
        }
    }
    
    func getMoviePoster(movieId: String) async -> Result<String, Error> {
        let endpointExt = "movie/\(movieId)/images?include_image_language=en"
        let url = URL(string: baseURL + endpointExt)!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(MovieAccess.shared.MOVIE_SECRET)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let imageResults = try? JSONDecoder().decode(MovieImageData.self, from: data) {
                if (imageResults.posters == nil || imageResults.posters!.count == 0) {
                    return .success("")
                }
                
                guard let halfsheet = imageResults.posters?[0].filePath else {
                    return .success("")
                }
                return .success(halfsheet)
            } else {
                return .failure(MovieError.decodingError)
            }
        } catch {
            return .failure(error)
        }
    }
    
    func searchMoviesByGenre(page: Int, genreId: String) async -> Result<MovieSearchData, Error> {
        let endpointExt = "discover/movie?include_adult=false&include_video=false&language=en-US&page=\(page)&sort_by=popularity.desc&with_genres=\(genreId)"
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
    
}
