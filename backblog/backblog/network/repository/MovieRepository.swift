//
//  MovieRepository.swift
//  backblog
//
//  Created by Jake Buhite on 1/25/24.
//

import FirebaseFirestore
import Foundation

class MovieRepository {
    
    static func addMovie(logId: String, movieId: String) async -> Result<Bool, Error> {
        do {
            let updates: [String: Any] = ["movie_ids.\(movieId)": true, "last_modified_date": String(currentTimeInMS())]
            let result = try await FirebaseService.shared.put(updates: updates, docId: logId, collection: "logs").get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    /*static func markMovie(logId: String, movieId: String, watched: Bool) async -> Result<Bool, Error> {
        do {
            if (watched) {
                // Movie has been marked as watched
                let updates: [String: Any] = ["movie_ids.\(movieId)": FieldValue.delete(), "watched_ids.\(movieId)": true, "last_modified_date: ": String(currentTimeInMS())]
                let response = try await FirebaseService.shared.put(updates: updates, docId: logId, collection: "logs").get()
                response
            } else {
                // Movie has been removed from watched
                let updates: [String: Any] = ["movie_ids.\(movieId)": FieldValue.delete(), "watched_ids.\(movieId)": true, "last_modified_date: ": String(currentTimeInMS())]
                let response = try await FirebaseService.shared.put(updates: updates, docId: logId, collection: "logs").get()
                response
            }
        } catch {
            return .failure(error)
        }
    }*/
    
    /*static func getWatchNextMovie(userId: String) async -> Result<MovieData, Error> {
        do {
            // Get log data
            let logs = try await LogRepository.getLogs(userId: userId, showPrivate: true).get()
            
            
        } catch {
            return .failure(error)
        }
    }*/
    
    static func searchMovie(query: String, page: Int) async -> Result<MovieSearchData, Error> {
        do {
            let result = try await MovieService.shared.searchMovie(query: query, includeAdult: false, language: "en-US", page: page).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    static func getMovieById(movieId: String) async -> Result<MovieData, Error> {
        do {
            let result = try await MovieService.shared.getMovieByID(movieId: movieId).get()
            
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
