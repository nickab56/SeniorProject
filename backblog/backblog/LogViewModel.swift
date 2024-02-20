//
//  LogViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import Foundation
import SwiftUI
import CoreData

class LogViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    @Published var movies: [(MovieData, String)] = [] // Pair of MovieData and half-sheet URL
    @Published var watchedMovies: [(MovieData, String)] = []
    @Published var showingWatchedNotification = false
    
    // Log Item View
    @Published var posterURL: URL?
    @Published var isLoading = true
    private let maxCharacters = 20
    
    @Published var log: LogType
    
    private var fb: FirebaseProtocol
    private var movieService: MovieService
    private var logRepo: LogRepository
    private var movieRepo: MovieRepository
    
    init(log: LogType, fb: FirebaseProtocol, movieService: MovieService) {
        self.log = log
        self.fb = fb
        self.movieService = movieService
        self.logRepo = LogRepository(fb: fb)
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
    }
    
    func fetchMovies() {
        guard case .localLog(let localLog) = log else { return }

        // Clear existing data
        movies = []
        watchedMovies = []

        // Fetch unwatched movies
        var unwatchedMovieEntities = localLog.movie_ids?.allObjects as? [LocalMovieData] ?? []
        unwatchedMovieEntities.sort { $0.movie_index < $1.movie_index }

        // Dispatch group to wait for all tasks to complete
        let group = DispatchGroup()

        for movieEntity in unwatchedMovieEntities {
            group.enter()
            Task {
                await fetchMovieDetails(movieId: movieEntity.movie_id ?? "", isWatched: false)
                group.leave()
            }
        }

        // Fetch watched movies
        var watchedMovieEntities = localLog.watched_ids?.allObjects as? [LocalMovieData] ?? []
        watchedMovieEntities.sort { $0.movie_index < $1.movie_index }

        for movieEntity in watchedMovieEntities {
            group.enter()
            Task {
                await fetchMovieDetails(movieId: movieEntity.movie_id ?? "", isWatched: true)
                group.leave()
            }
        }

        // Notify when all tasks are completed
        group.notify(queue: .main) {
            self.movies.sort { entityA, entityB in
                let i = unwatchedMovieEntities.firstIndex(where: { $0.movie_id == String(entityA.0.id ?? 0) } ) ?? Int.max
                let i2 = unwatchedMovieEntities.firstIndex(where: { $0.movie_id == String(entityB.0.id ?? 0) } ) ?? Int.max
                return i < i2
            }
            
            self.watchedMovies.sort { entityA, entityB in
                let i = watchedMovieEntities.firstIndex(where: { $0.movie_id == String(entityA.0.id ?? 0) } ) ?? Int.max
                let i2 = watchedMovieEntities.firstIndex(where: { $0.movie_id == String(entityB.0.id ?? 0) } ) ?? Int.max
                return i < i2
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
            let movieIds = localLog.movie_ids?.allObjects as? [LocalMovieData] ?? []
            let movieEntity = movieIds.first(where: { $0.movie_id == String(movieId) })
            if (movieEntity != nil) {
                localLog.removeFromMovie_ids(movieEntity!)
                
                movieEntity?.movie_index = Int64(localLog.watched_ids?.count ?? 0)
                localLog.addToWatched_ids(movieEntity!)

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
            let movieIds = localLog.watched_ids?.allObjects as? [LocalMovieData] ?? []
            let movieEntity = movieIds.first(where: { $0.movie_id == String(movieId) })
            if (movieEntity != nil) {
                localLog.removeFromWatched_ids(movieEntity!)
                
                movieEntity?.movie_index = Int64(localLog.movie_ids?.count ?? 0)
                localLog.addToMovie_ids(movieEntity!)

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
                        guard (fb.getUserId()) != nil else {
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
            (local.movie_ids?.allObjects as? [LocalMovieData])?.sorted(by: { $0.movie_index < $1.movie_index }).first?.movie_id
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
    
    // Function to remove a movie from a local log
    func removeMovie(movieId: Int) {
        guard case .localLog(let localLog) = log else { return }

        if let index = movies.firstIndex(where: { $0.0.id == movieId }) {
            movies.remove(at: index)

            // Update Core Data model
            let movieArr = localLog.movie_ids?.allObjects as? [LocalMovieData] ?? []
            if let movieEntity = movieArr.first(where: { $0.movie_id == String(movieId) }) {
                localLog.removeFromMovie_ids(movieEntity)

                do {
                    try viewContext.save()
                } catch {
                    print("Error removing movie from Core Data: \(error.localizedDescription)")
                }
            }
        }
    }

    // Function to reorder movies within a local log
    func reorderMovies(from source: IndexSet, to destination: Int) {
        guard case .localLog(let localLog) = log else { return }
        let movieIds = localLog.movie_ids

        // Reorder movies array
        movies.move(fromOffsets: source, toOffset: destination)

        // Reorder Core Data model's movie_ids
        var reorderedMovieIds = movieIds?.allObjects as? [LocalMovieData] ?? []
        reorderedMovieIds.move(fromOffsets: source, toOffset: destination)
        localLog.movie_ids = NSSet(array: reorderedMovieIds)

        do {
            try viewContext.save()
        } catch {
            print("Error reordering movies in Core Data: \(error.localizedDescription)")
        }
    }
    
    func updateLogName(newName: String) {
        guard case .localLog(let localLog) = log else { return }
        localLog.name = newName
        do {
            try viewContext.save()
        } catch {
            print("Error saving updated log name: \(error.localizedDescription)")
        }
    }

    // EDIT LOG SHEET VIEW
    func deleteDraftMovie(movies: [(MovieData, String)], at offsets: IndexSet) -> [(MovieData, String)] {
        var newMovies = movies
        newMovies.remove(atOffsets: offsets)
        return newMovies
    }

    func moveDraftMovies(movies: [(MovieData, String)], from source: IndexSet, to destination: Int) -> [(MovieData, String)] {
        var newMovies = movies
        newMovies.move(fromOffsets: source, toOffset: destination)
        return newMovies
    }

    func saveChanges(draftLogName: String, movies: [(MovieData, String)]) {
        // Apply changes from draft state to the view model
        updateLogName(newName: draftLogName)
        
        // Update view model
        self.movies = movies
        
        // Update log object
        guard case .localLog(let localLog) = log else { return }
        var updatedArray: [LocalMovieData] = []
        for (index, e) in movies.enumerated() {
            let movieData = LocalMovieData(context: self.viewContext)
            movieData.movie_id = String(e.0.id ?? 0)
            movieData.movie_index = Int64(index)
            updatedArray.append(movieData)
        }
        
        localLog.movie_ids = NSSet(array: updatedArray)
        do {
            try viewContext.save()
        } catch {
            print("Error saving changes to Core Data: \(error.localizedDescription)")
        }
    }
}

