//
//  MovieRepository.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import FirebaseFirestore
import Foundation

class MovieRepository {
    let fb: FirebaseProtocol
    let movieService: MovieProtocol
    
    init(fb: FirebaseProtocol, movieService: MovieProtocol) {
        self.fb = fb
        self.movieService = movieService
    }
    
    func addMovie(logId: String, movieId: String) async -> Result<Bool, Error> {
        do {
            let updates: [String: Any] = ["movie_ids": FieldValue.arrayUnion([movieId]), "last_modified_date": String(currentTimeInMS())]
            let result = try await fb.put(updates: updates, docId: logId, collection: "logs").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func markMovie(logId: String, movieId: String, watched: Bool) async -> Result<Bool, Error> {
        do {
            let updates: [String: Any] = if (watched) {
                // Movie has been marked as watched
                ["movie_ids": FieldValue.arrayRemove([movieId]), "watched_ids": FieldValue.arrayUnion([movieId]), "last_modified_date": String(currentTimeInMS())]
            } else {
                // Movie has been removed from watched
                ["movie_ids": FieldValue.arrayUnion([movieId]), "watched_ids": FieldValue.arrayRemove([movieId]), "last_modified_date": String(currentTimeInMS())]
            }
            
            let result = try await fb.put(updates: updates, docId: logId, collection: "logs").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getWatchNextMovie(userId: String) async -> Result<(String, LogData)?, Error> {
        do {
            // Get log data
            let logs = try await LogRepository(fb: fb).getLogs(userId: userId, showPrivate: true).get()
            
            if (logs.isEmpty) {
                return .success(nil)
            }
            
            var priorityLog: LogData? = nil
            var highestPriority = Int.max
            
            logs.forEach{ log in
                let userPriority = if (log.owner?.userId == userId) {
                    log.owner!.priority!
                } else {
                    log.order?[userId]
                }
                
                if (userPriority != nil && userPriority! < highestPriority && (log.movieIds != nil && !log.movieIds!.isEmpty)) {
                    highestPriority = userPriority!
                    priorityLog = log
                }
            }
            
            if (priorityLog == nil) {
                return .success(nil)
            }
            
            let movieId = priorityLog!.movieIds!.first!
            let logData = priorityLog!
            
            return .success((movieId, logData))
        } catch {
            return .failure(error)
        }
    }
    
    func searchMovie(query: String, page: Int) async -> Result<MovieSearchData, Error> {
        do {
            let result = try await movieService.searchMovie(query: query, includeAdult: false, language: "en-US", page: page).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getMovieById(movieId: String) async -> Result<MovieData, Error> {
        do {
            let result = try await movieService.getMovieByID(movieId: movieId).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getMovieHalfSheet(movieId: String) async -> Result<String, Error> {
        do {
            let result = try await movieService.getMovieHalfSheet(movieId: movieId).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getMoviePoster(movieId: String) async -> Result<String, Error> {
        do {
            let result = try await movieService.getMoviePoster(movieId: movieId).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func getMoviesByGenre(genreId: String) async -> Result<MovieSearchData, Error> {
        do {
            let result = try await movieService.searchMoviesByGenre(page: 1, genreId: genreId).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
