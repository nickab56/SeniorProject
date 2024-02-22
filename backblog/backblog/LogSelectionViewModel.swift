//
//  LogSelectionViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/21/24.
//

import Foundation
import CoreData

class LogSelectionViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    @Published var selectedMovieId: Int
    @Published var logs: [LogType] = []
    @Published var selectedLogs: Set<String> = Set()
    @Published var logsWithDuplicates: Set<String> = Set()
    @Published var showingNotification = false
    
    private let fb = FirebaseService()
    private let movieService = MovieService()
    private let logRepo: LogRepository
    private let movieRepo: MovieRepository
    private let userId: String?
    
    init(selectedMovieId: Int) {
        self.selectedMovieId = selectedMovieId
        self.logRepo = LogRepository(fb: fb)
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
        self.userId = fb.getUserId()
        getLogs()
    }
    
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
    
    private func getLocalLogs() -> [LocalLogData] {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
        return []
    }
    
    func getTitle(logType: LogType) -> String {
        switch logType {
        case .log(let log):
            return log.name ?? "Unknown Log"
        case .localLog(let log):
            return log.name ?? "Unknown Log"
        }
    }
    
    func getLogId(logType: LogType) -> String {
        switch logType {
        case .log(let log):
            return log.logId ?? ""
        case .localLog(let log):
            return String(log.log_id)
        }
    }
    
    func isLogSelected(logType: LogType) -> Bool {
        return selectedLogs.contains(getLogId(logType: logType))
    }
}
