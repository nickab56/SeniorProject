//
//  LogSelectionViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/21/24.
//

import Foundation
import CoreData

class LogSelectionViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext // Core Data context for local operations.
    @Published var selectedMovieId: Int // The id of the movie to be added to logs.
    @Published var logs: [LogType] = [] // The list of available logs.
    @Published var selectedLogs: Set<String> = Set() // The logs selected by the user to add the movie to.
    @Published var logsWithDuplicates: Set<String> = Set() // Logs that already contain the movie.
    @Published var showingNotification = false // Controls the visibility of notifications/alerts.
    
    private let fb = FirebaseService() // Firebase service for remote operations.
    private let movieService = MovieService() // Movie service for API interactions.
    private let logRepo: LogRepository // Repository for log data fetching.
    private let movieRepo: MovieRepository // Repository for movie data fetching.
    private let userId: String? // The current user's ID, if authenticated.
    
    init(selectedMovieId: Int) {
        self.selectedMovieId = selectedMovieId
        self.logRepo = LogRepository(fb: fb)
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
        self.userId = fb.getUserId()
        getLogs()
    }
    
    /**
     Fetches the list of available logs for the current user.
     */
    func getLogs() {
        if (userId != nil) {
            // Check if authenticated
            DispatchQueue.main.async {
                Task {
                    do {
                        let result = try await self.logRepo.getLogs(userId: self.userId!, showPrivate: true).get()
                        self.logs = result.map { LogType.log($0) }
                    } catch {
                        print("Error getting logs \(error)")
                    }
                }
            }
        } else {
            // Use local (not authenticated)
            logs = getLocalLogs().map { LogType.localLog($0) }
        }
    }

    /**
     Handles the selection or deselection of a log for adding the movie.
     
     - Parameters:
         - logId: The ID of the log to be toggled.
     */
    func handleLogSelection(logId: String) {
        if isDuplicateInLog(logId: logId) {
            // If the movie is already in the log, show notification and don't change selection
            showingNotification = true
        } else {
            // If the movie is not in the log, toggle selection
            if selectedLogs.contains(logId) {
                selectedLogs.remove(logId)
            } else {
                selectedLogs.insert(logId)
            }
        }
    }

    
    /**
     Checks if the selected movie already exists in the specified log.
     
     - Parameters:
         - logId: The ID of the log to be checked.
     
     - Returns: A Boolean indicating if the movie is a duplicate in the log.
     */
    func isDuplicateInLog(logId: String) -> Bool {
        if (userId != nil) {
            let logList: [LogData] = self.logs.compactMap { logType in
                if case let .log(logData) = logType {
                    return logData
                }
                return nil
            }
            if let log = logList.first(where: { $0.logId == logId }) {
                if let movieIds = log.movieIds {
                    for movie in movieIds {
                        if movie == String(selectedMovieId) {
                            return true
                        }
                    }
                }
            }
        } else {
            let localLogs: [LocalLogData] = logs.compactMap { logType in
                if case let .localLog(localLogData) = logType {
                    return localLogData
                }
                return nil
            }
            if let log = localLogs.first(where: { String($0.log_id) == logId }) {
                if let movieIds = log.movie_ids as? Set<LocalMovieData> {
                    for movie in movieIds {
                        if movie.movie_id == String(selectedMovieId) {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }



    /**
     Adds the selected movie to all selected logs.
     */
    func addMovieToSelectedLogs() {
        if (userId != nil) {
            DispatchQueue.main.async {
                Task { [self] in
                    do {
                        let logList: [LogData] = self.logs.compactMap { logType in
                            if case let .log(logData) = logType {
                                return logData
                            }
                            return nil
                        }
                        _ = try await withThrowingTaskGroup(of: Bool.self) { group in
                            for (_, e) in self.selectedLogs.enumerated() {
                                group.addTask {
                                    do {
                                        if let log = logList.first(where: { $0.logId == e }) {
                                            // Check if the movie is already in the watched list
                                            if let watchedMovie = log.watchedIds, let movieToMove = watchedMovie.first(where: { $0 == String(self.selectedMovieId) }) {
                                                // Move the movie from watched to unwatched list
                                                return try await self.movieRepo.markMovie(logId: e, movieId: movieToMove, watched: false).get()
                                            } else if !self.isDuplicateInLog(logId: e) {
                                                // The movie is not in the unwatched or watched list, add a new entry
                                                return try await self.movieRepo.addMovie(logId: e, movieId: String(self.selectedMovieId)).get()
                                            }
                                        }
                                        return true
                                    } catch {
                                        print("Error updating userId: \(error)")
                                        throw error
                                    }
                                }
                            }
                            
                            for try await result in group {
                                if (!result) {
                                    throw FirebaseError.failedTransaction
                                }
                            }
                                
                            return true
                        }
                    } catch {
                        print("Error adding movie to selected logs \(error)")
                    }
                }
            }
        } else {
            let localLogs: [LocalLogData] = logs.compactMap { logType in
                if case let .localLog(localLogData) = logType {
                    return localLogData
                }
                return nil
            }
            selectedLogs.forEach { logId in
                if let log = localLogs.first(where: { String($0.log_id) == logId }) {
                    // Check if the movie is already in the watched list
                    if let watchedMovie = log.watched_ids as? Set<LocalMovieData>, let movieToMove = watchedMovie.first(where: { $0.movie_id == String(selectedMovieId) }) {
                        // Move the movie from watched to unwatched list
                        log.removeFromWatched_ids(movieToMove)
                        movieToMove.movie_index = Int64(log.movie_ids?.count ?? 0) // Update the index for the unwatched list
                        log.addToMovie_ids(movieToMove)
                    } else if !isDuplicateInLog(logId: String(log.log_id)) {
                        // The movie is not in the unwatched or watched list, add a new entry
                        let newMovie = LocalMovieData(context: viewContext)
                        newMovie.movie_id = String(selectedMovieId)
                        newMovie.movie_index = Int64(log.movie_ids?.count ?? 0)
                        log.addToMovie_ids(newMovie)
                    }
                    
                    // Save changes
                    do {
                        try viewContext.save()
                    } catch {
                        print("Error updating movie lists: \(error)")
                    }
                }
            }
        }
    }
    
    /**
     Fetches all local logs stored in Core Data.
     
     - Returns: An array of `LocalLogData` representing the local logs.
     */
    private func getLocalLogs() -> [LocalLogData] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()

        do {
            let items = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.logs = items.map { LogType.localLog($0) }
            }
        } catch {
            print("Error fetching local logs: \(error)")
        }
        return []
    }
    
    /**
     Retrieves the title of a given log.
     
     - Parameters:
         - logType: The `LogType` enum instance representing the log.
     
     - Returns: The title of the log as a string.
     */
    func getTitle(logType: LogType) -> String {
        switch logType {
        case .log(let log):
            return log.name ?? "Unknown Log"
        case .localLog(let log):
            return log.name ?? "Unknown Log"
        }
    }
    
    /**
     Retrieves the ID of a given log.
     
     - Parameters:
         - logType: The `LogType` enum instance representing the log.
     
     - Returns: The ID of the log as a string.
     */
    func getLogId(logType: LogType) -> String {
        switch logType {
        case .log(let log):
            return log.logId ?? ""
        case .localLog(let log):
            return String(log.log_id)
        }
    }
    
    /**
     Checks if a given log is selected.
     
     - Parameters:
         - logType: The `LogType` enum instance representing the log.
     
     - Returns: A Boolean indicating if the log is selected.
     */
    func isLogSelected(logType: LogType) -> Bool {
        return selectedLogs.contains(getLogId(logType: logType))
    }
    
    func createNewLogWithName(_ name: String) {
        if let userId = self.userId {
            // User is authenticated, create the log remotely
            Task {
                do {
                    let newLogId = try await logRepo.addLog(name: name, isVisible: true, ownerId: userId).get()
                    print("Successfully created new log with ID \(newLogId) in Firebase")
                    
                    await getLogs()
                } catch {
                    print("Error creating new log: \(error.localizedDescription)")
                }
            }
        } else {
            // User is not authenticated, create the log locally
            let newLog = LocalLogData(context: viewContext)
            newLog.name = name
            newLog.log_id = Int64(UUID().hashValue)

            do {
                getLocalLogs()
                try viewContext.save()
                print("Successfully created new local log with name \(name)")
                
            } catch {
                print("Error saving new local log: \(error.localizedDescription)")
            }
        }
    }


}
