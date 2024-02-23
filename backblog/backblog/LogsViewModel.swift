//
//  LogsViewModel.swift
//  backblog
//
//  Created by Nick Abegg on 2/4/24.
//  Updated by Jake Buhite on 2/22/24
//

import Foundation
import SwiftUI
import CoreData

class LogsViewModel: ObservableObject {
    @Published var logs: [LogType] = []
    @Published var refreshTrigger: Bool = false
    @Published var isLoggedInToSocial = false
    
    // What's Next
    @Published var nextLogName: String = "Unknown"
    @Published var nextMovie: String?  // The next movie to watch
    @Published var movieTitle: String = "Loading..."
    @Published var movieDetails: String = "Loading details..."
    @Published var halfSheetImage: Image = Image("img_placeholder_poster")
    
    @Published var hasWatchNextMovie = false
    
    // Add Log Sheet View
    @Published var friends: [UserData] = []
    
    private var fb: FirebaseProtocol
    private var movieService: MovieService
    private let viewContext = PersistenceController.shared.container.viewContext
    
    let movieRepo: MovieRepository
    let logRepo: LogRepository
    let friendRepo: FriendRepository
    
    init(fb: FirebaseProtocol, movieService: MovieService) {
        self.fb = fb
        self.movieService = movieService
        self.logRepo = LogRepository(fb: fb)
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
        self.friendRepo = FriendRepository(fb: fb)
    }
    
    func addLog(name: String, isVisible: Bool, collaborators: [String]) {
        DispatchQueue.main.async {
            Task {
                do {
                    guard let userId = self.fb.getUserId() else {
                        return
                    }
                    let result = try await self.logRepo.addLog(name: name, isVisible: isVisible, ownerId: userId).get()
                    _ = try await self.logRepo.addCollaborators(logId: result, collaborators: collaborators).get()
                } catch {
                    print("Error creating remote log: \(error)")
                }
            }
        }
    }
    
    func fetchLogs() {
        // Check whether user is logged in
        if let userId = fb.getUserId() {
            DispatchQueue.main.async {
                Task {
                    do {
                        let result = try await self.logRepo.getLogs(userId: userId, showPrivate: true).get()
                        self.logs = result.compactMap { log in
                            return LogType.log(log)
                        }
                    } catch {
                        print("Error getting log data: \(error)")
                    }
                }
            }
        } else {
            let result = getLocalLogs()
            logs = result.compactMap { localLog in
                return LogType.localLog(localLog)
            }
        }
    }
    
    func getFriends() {
        DispatchQueue.main.async {
            Task {
                do {
                    guard let userId = self.fb.getUserId() else {
                        return
                    }
                    let result = try await self.friendRepo.getFriends(userId: userId).get()
                    self.friends = result
                } catch {
                    print("Error getting friends: \(error)")
                }
            }
        }
    }
    
    func loadNextUnwatchedMovie() {
        switch (logs.first) {
        case .log(_):
            DispatchQueue.main.async {
                Task {
                    do {
                        guard let userId = self.fb.getUserId() else {
                            return
                        }
                        let result = try await self.movieRepo.getWatchNextMovie(userId: userId).get()
                        
                        if let (nextMovie, nextLogName) = result {
                            // Fetch and display movie details
                            self.nextMovie = nextMovie
                            self.nextLogName = nextLogName
                            self.loadMovieDetails(movie: nextMovie)
                            self.hasWatchNextMovie = true
                        } else {
                            // Handle case where there are no unwatched movies
                            self.nextLogName = ""
                            self.movieTitle = "All Caught Up!"
                            self.movieDetails = "You've watched all the movies in this log."
                            self.hasWatchNextMovie = false
                        }
                    } catch {
                        print("Error getting log data: \(error)")
                    }
                }
            }
        case .localLog(_):
            let logList: [LocalLogData] = logs.compactMap { logType in logType.toLocalLog() }
            
            // Find first one with movies
            guard let localLog = logList.first(where: { $0.movie_ids?.count ?? 0 > 0 }) else {
                // Handle case where there are no unwatched movies
                movieTitle = "All Caught Up!"
                movieDetails = "You've watched all the movies in your logs."
                self.hasWatchNextMovie = false
                return
            }
            
            let unwatchedMovies = localLog.movie_ids?.allObjects as? [LocalMovieData] ?? []
            let nextUnwatchedMovie = unwatchedMovies.first(where: { $0.movie_index == 0 })

            nextMovie = nextUnwatchedMovie?.movie_id  // Update the state to reflect the next unwatched movie

            if let nextMovie = nextMovie {
                // Fetch and display movie details
                self.nextLogName = localLog.name ?? "Unknown"
                self.loadMovieDetails(movie: nextMovie)
                self.hasWatchNextMovie = true
            } else {
                // Handle case where there are no unwatched movies
                movieTitle = "All Caught Up!"
                movieDetails = "You've watched all the movies in your logs."
                self.hasWatchNextMovie = false
            }
        default:
            // Handle case where there are no unwatched movies
            movieTitle = "All Caught Up!"
            movieDetails = "You've watched all the movies in your logs."
            self.hasWatchNextMovie = false
        }
    }

    func loadMovieDetails(movie: String?) {
        guard let movieId = movie else { return }
        
        Task {
            // Fetch movie details
            let movieDetailsResult = await movieRepo.getMovieById(movieId: movieId)
            if case .success(let movieData) = movieDetailsResult {
                DispatchQueue.main.async { [self] in
                    movieTitle = movieData.title ?? "Unknown Title"
                    let releaseYear = movieData.releaseDate?.prefix(4) ?? "Year Unknown"
                    movieDetails = "\(movieData.runtime ?? 0) min · \(releaseYear)"
                }

                // Fetch half-sheet image
                let halfSheetResult = await movieRepo.getMovieHalfSheet(movieId: movieId)
                if case .success(let halfSheetPath) = halfSheetResult, let url = URL(string: "https://image.tmdb.org/t/p/w500\(halfSheetPath)") {
                    let _ = ImageLoader.loadImage(from: url) { image in
                        DispatchQueue.main.async { [self] in
                            halfSheetImage = Image(uiImage: image)
                        }
                    }
                }
            }
        }
    }

    func markMovieAsWatched(log: LogType) {
        guard let movie = nextMovie else { return }
        
        switch (log) {
        case .log(let log):
            DispatchQueue.main.async {
                Task {
                    do {
                        let unwatchedMovies = log.watchedIds ?? []
                        guard let movieId = unwatchedMovies.first(where: { $0 == movie }), let logId = log.logId else {
                            return
                        }
                        
                        _ = try await self.movieRepo.markMovie(logId: logId, movieId: movieId, watched: true).get()
                        self.loadNextUnwatchedMovie() // Refresh the view to show the next unwatched movie
                    } catch {
                        print("Error getting log data: \(error)")
                    }
                }
            }
        case .localLog(let localLog):
            // Add the movie to the watched list
            let unwatchedMovies = localLog.movie_ids?.allObjects as? [LocalMovieData] ?? []
            guard let movieData = unwatchedMovies.first(where: { $0.movie_id == movie }) else {
                return
            }
                
            // Remove the movie from the unwatched list
            localLog.removeFromMovie_ids(movieData)
                
            movieData.movie_index = Int64(localLog.watched_ids?.count ?? 0)
            localLog.addToWatched_ids(movieData)

            // Save changes to the data store
            do {
                try viewContext.save()
                loadNextUnwatchedMovie()  // Refresh the view to show the next unwatched movie
            } catch {
                print("Error marking movie as watched: \(error.localizedDescription)")
            }
        }
    }
    
    func updateLogsOrder(logs: [LogData]) {
        DispatchQueue.main.async {
            Task {
                do {
                    guard let userId = self.fb.getUserId() else {
                        return
                    }
                    let updates: [(String, Bool)] = logs.compactMap { log in
                        if let logId = log.logId {
                            let ownsLog: Bool = log.owner?.userId == userId
                            return (logId, ownsLog)
                        }
                        return nil
                    }
                    _ = try await self.logRepo.updateUserLogOrder(userId: userId, logIds: updates).get()
                } catch {
                    print("Error updating log order: \(error)")
                }
            }
        }
    }
    
    func getUserId() -> String? {
        return fb.getUserId()
    }
    
    private func getLocalLogs() -> [LocalLogData] {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(LocalLogData.orderIndex), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
        return []
    }

}

// ImageLoader for fetching images from URLs
class ImageLoader {
    static func loadImage(from url: URL, completion: @escaping (UIImage) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            completion(image)
        }
        task.resume()
        return task
    }
}

