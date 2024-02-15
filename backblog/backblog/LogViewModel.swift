//
//  LogViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import Foundation
import SwiftUI

class LogViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    @Published var movies: [(MovieData, String)] = [] // Pair of MovieData and half-sheet URL
    @Published var watchedMovies: [(MovieData, String)] = []
    @Published var showingWatchedNotification = false
    
    // Log Item View
    @Published var posterURL: URL?
    @Published var isLoading = true
    private let maxCharacters = 20
    
    var log: LogType
    
    let fb = FirebaseService()
    private let movieService = MovieService()
    private var logRepo: LogRepository
    private var movieRepo: MovieRepository
    
    init(log: LogType) {
        self.log = log
        self.logRepo = LogRepository(fb: fb)
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
    }
    
    func fetchMovies() {
        guard case .localLog(let localLog) = log else { return }

        // Clear existing data
        movies = []
        watchedMovies = []

        // Fetch unwatched movies
        if let unwatchedMovieEntities = localLog.movie_ids as? Set<LocalMovieData> {
            for movieEntity in unwatchedMovieEntities {
                Task {
                    await fetchMovieDetails(movieId: movieEntity.movie_id ?? "", isWatched: false)
                }
            }
        }

        // Fetch watched movies
        if let watchedMovieEntities = localLog.watched_ids as? Set<LocalMovieData> {
            for movieEntity in watchedMovieEntities {
                Task {
                    await fetchMovieDetails(movieId: movieEntity.movie_id ?? "", isWatched: true)
                }
            }
        }
    }

    
    func fetchMovieDetails(movieId: String, isWatched: Bool) async {
        let movieDetailsResult = await movieRepo.getMovieById(movieId: movieId)
        let halfSheetResult = await movieRepo.getMovieHalfSheet(movieId: movieId)

        await MainActor.run {
            switch (movieDetailsResult, halfSheetResult) {
            case (.success(let movieData), .success(let halfSheetPath)):
                let fullPath = "https://image.tmdb.org/t/p/w500\(halfSheetPath)"
                let movieTuple = (movieData, fullPath)
                if isWatched {
                    watchedMovies.append(movieTuple)
                } else {
                    movies.append(movieTuple)
                }
            case (.failure(let error), _), (_, .failure(let error)):
                print("Error fetching movie by ID or half-sheet: \(error.localizedDescription)")
            }
        }
    }
    
    func markMovieAsWatched(movieId: Int) {
        guard case .localLog(let localLog) = log else { return }

        if let index = movies.firstIndex(where: { $0.0.id == movieId }) {
            let movieTuple = movies.remove(at: index)
            watchedMovies.append(movieTuple)

            // Update Core Data model
            if let movieEntity = (localLog.movie_ids as? Set<LocalMovieData>)?.first(where: { $0.movie_id == String(movieId) }) {
                localLog.removeFromMovie_ids(movieEntity)
                localLog.addToWatched_ids(movieEntity)

                do {
                    try viewContext.save()
                    showingWatchedNotification = true
                } catch {
                    print("Error updating watched status in Core Data: \(error.localizedDescription)")
                }
            }
        }
    }

    func markMovieAsUnwatched(movieId: Int) {
        guard case .localLog(let localLog) = log else { return }

        // Find the movie in the watchedMovies list
        if let index = watchedMovies.firstIndex(where: { $0.0.id == movieId }) {
            let movieTuple = watchedMovies.remove(at: index)
            movies.append(movieTuple)

            // Update Core Data model
            if let movieEntity = (localLog.watched_ids as? Set<LocalMovieData>)?.first(where: { $0.movie_id == String(movieId) }) {
                localLog.removeFromWatched_ids(movieEntity)
                localLog.addToMovie_ids(movieEntity)

                do {
                    try viewContext.save()
                } catch {
                    print("Error updating unwatched status in Core Data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func localMovieDataMapping(movieSet: Set<LocalMovieData>?) -> [String] {
        guard let movies: Set<LocalMovieData> = movieSet, !(movies.count == 0) else { return [] }
        
        return movies.compactMap { $0.movie_id  }
    }

    func deleteLog() {
        do {
            switch log {
            case .localLog(let log):
                viewContext.delete(log)
                try viewContext.save()
            case .log(let log):
                DispatchQueue.main.async { [self] in
                    Task {
                        guard (fb.auth.currentUser?.uid) != nil else {
                            return
                        }
                        do {
                            guard let logId = log.logId else { return }
                            _ = try await logRepo.deleteLog(logId: logId).get()
                        } catch {
                            throw error
                        }
                    }
                }
            }
        } catch {
            print("Error deleting log: \(error.localizedDescription)")
        }
    }
    
    func fetchMoviePoster() {
        if (!logContainsMovies()) {
            isLoading = false
            return
        }
        
        guard let movieId: String = switch log {
        case .localLog(let local):
            (local.movie_ids?.allObjects.first as? LocalMovieData)?.movie_id
        case .log(let log):
            log.movieIds?.first
        } else {
            isLoading = false
            return
        }

        Task {
            let result = await movieRepo.getMoviePoster(movieId: movieId)
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let posterPath):
                    if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                        self.posterURL = posterURL
                    }
                case .failure:
                    print("Failed to load movie poster")
                }
                isLoading = false
            }
        }
    }

    func logContainsMovies() -> Bool {
        return switch log {
        case .localLog(let local):
            local.movie_ids?.count ?? 0 > 0
        case .log(let log):
            log.movieIds?.count ?? 0 > 0
        }
    }

    func truncateText(_ text: String) -> String {
        if text.count > maxCharacters {
            return String(text.prefix(maxCharacters)) + "..."
        } else {
            return text
        }
    }
}

