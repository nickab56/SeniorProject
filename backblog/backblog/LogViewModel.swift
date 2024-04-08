//
//  LogViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//  Updated by Jake Buhite on 2/23/24.
//
//  Description: Manages the data and business logic of a log, including
//  its movies and collaborators.
//
import Foundation
import SwiftUI
import CoreData
import Firebase

/**
 Manages the data and business logic of a log, including its movies and collaborators.
 
 - Parameters:
     - log: A log wrapped in `LogType`.
     - fb: The `FirebaseProtocol` for Firebase operations.
     - movieService: The `MovieService` for handling interactions with TMDB.
 */
class LogViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    @Published var movies: [(MovieData, String)] = [] // Pair of MovieData and half-sheet URL
    @Published var watchedMovies: [(MovieData, String)] = []
    @Published var showingWatchedNotification = false
    @Published var isActive = true
    
    @Published var logDeleted = false
    
    // State vars for editing log
    @Published var isOwner = false
    @Published var isCollaborator = false
    
    // Log Item View
    @Published var posterURL: URL?
    @Published var isLoading = true
    private let maxCharacters = 20
    
    @Published var log: LogType
    
    @Published var ownerData: UserData?
    
    private var fb: FirebaseProtocol
    private var movieService: MovieProtocol
    private var logRepo: LogRepository
    private var movieRepo: MovieRepository
    private var friendRepo: FriendRepository
    private var userRepo: UserRepository
    
    // Listeners
    private var logListener: ListenerRegistration?
    
    // Collaborators
    @Published var collaborators: [UserData] = []
    @Published var friends: [UserData] = []
    
    /**
     Initializes the `LogViewModel` with the specific `LogType`, `FirebaseProtocol`, and `MovieService`.
     
     - Parameters:
     - log: A log wrapped in `LogType`.
     - fb: The `FirebaseProtocol` for Firebase operations.
     - movieService: The `MovieService` for handling interactions with TMDB.
     */
    init(log: LogType, fb: FirebaseProtocol, movieService: MovieProtocol) {
        self.log = log
        self.fb = fb
        self.movieService = movieService
        self.logRepo = LogRepository(fb: fb)
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
        self.friendRepo = FriendRepository(fb: fb)
        self.userRepo = UserRepository(fb: fb)
        self.isOwner = updateIsOwner()
        initLogListener()
    }
    
    deinit {
        removeListener()
    }

    /**
     Fetches movies for the log based on its type, updating the `movies` and `watchedMovies` arrays.
     */
    func fetchMovies() {
        switch (log) {
        case .localLog(let localLog):
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
        case .log(let fbLog):
            // Fetch unwatched movies
            let unwatchedMovies = fbLog.movieIds ?? []
            
            // Dispatch group to wait for all tasks to complete
            let group = DispatchGroup()
            
            for movieId in unwatchedMovies {
                group.enter()
                Task {
                    if (!self.movies.contains(where: { String($0.0.id ?? 0) == movieId })) {
                        await fetchMovieDetails(movieId: movieId, isWatched: false)
                    }
                    group.leave()
                }
            }
            
            // Fetch watched movies
            let watchedMovies = fbLog.watchedIds ?? []
            
            for movieId in watchedMovies {
                group.enter()
                Task {
                    if (!self.watchedMovies.contains(where: { String($0.0.id ?? 0) == movieId })) {
                        await fetchMovieDetails(movieId: movieId, isWatched: true)
                    }
                    group.leave()
                }
            }
            
            // Notify when all tasks are completed
            group.notify(queue: .main) {
                self.movies.sort { entityA, entityB in
                    let i = unwatchedMovies.firstIndex(where: { $0 == String(entityA.0.id ?? 0) } ) ?? Int.max
                    let i2 = unwatchedMovies.firstIndex(where: { $0 == String(entityB.0.id ?? 0) } ) ?? Int.max
                    return i < i2
                }
                
                self.watchedMovies.sort { entityA, entityB in
                    let i = watchedMovies.firstIndex(where: { $0 == String(entityA.0.id ?? 0) } ) ?? Int.max
                    let i2 = watchedMovies.firstIndex(where: { $0 == String(entityB.0.id ?? 0) } ) ?? Int.max
                    return i < i2
                }
            }
        }
    }
    
    /**
     Fetches details for a specific movie, including its data and half-sheet URL.
     
     - Parameters:
     - movieId: The id of the movie to fetch.
     - isWatched: A boolean value indicating whether the movie is watched or unwatched.
     */
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
    
    /**
     Marks a movie as watched, updating the `watchedMovies` array and Firebase/CoreData model appropriately.
     
     - Parameters:
     - movieId: The id of the movie to mark as watched.
     */
    func markMovieAsWatched(movieId: Int) {
        switch (log) {
        case .log(let log):
            if let index = movies.firstIndex(where: { $0.0.id == movieId }) {
                let movieTuple = movies.remove(at: index)
                watchedMovies.append(movieTuple)
                
                // Update Firebase
                DispatchQueue.main.async { [self] in
                    Task {
                        guard (fb.getUserId()) != nil else {
                            return
                        }
                        do {
                            _ = try await movieRepo.markMovie(logId: log.logId ?? "", movieId: String(movieId), watched: true).get()
                            showingWatchedNotification = true
                        } catch {
                            print("Error updating watched status in Firebase: \(error.localizedDescription)")
                        }
                    }
                }
            }
        case .localLog(let localLog):
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
    }
    
    /**
     Marks a movie as unwatched, updating the `watchedMovies` array and CoreData model.
     
     - Parameters:
     - movieId: The id of the movie to mark as unwatched.
     */
    func markMovieAsUnwatched(movieId: Int) {
        switch (log) {
        case .log(let log):
            if let index = watchedMovies.firstIndex(where: { $0.0.id == movieId }) {
                let movieTuple = watchedMovies.remove(at: index)
                movies.append(movieTuple)
                
                // Update Firebase
                DispatchQueue.main.async { [self] in
                    Task {
                        guard (fb.getUserId()) != nil else {
                            return
                        }
                        do {
                            _ = try await movieRepo.markMovie(logId: log.logId ?? "", movieId: String(movieId), watched: false).get()
                        } catch {
                            print("Error updating watched status in Firebase: \(error.localizedDescription)")
                        }
                    }
                }
            }
        case .localLog(let localLog):
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
    }
    
    /**
     Returns an array of movie id strings.
     
     - Parameters:
     - movieId: The list of `LocalMovieData` from the CoreData model.
     */
    func localMovieDataMapping(movieSet: Set<LocalMovieData>?) -> [String] {
        guard let movies: Set<LocalMovieData> = movieSet, !(movies.count == 0) else { return [] }
        
        return movies.compactMap { $0.movie_id  }
    }
    
    /**
     Deletes the log, removing it from CoreData or Firebase as appropriate.
     */
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
    
    /**
     Fetches the poster URL for the movie.
     */
    func fetchMoviePoster() {
        isLoading = true
        if (!logContainsMovies()) {
            posterURL = nil
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
    
    /**
     Checks if the log contains any movies.
     
     - Returns: A boolean value indicating if the log contains movies.
     */
    func logContainsMovies() -> Bool {
        return switch log {
        case .localLog(let local):
            local.movie_ids?.count ?? 0 > 0
        case .log(let log):
            log.movieIds?.count ?? 0 > 0
        }
    }
    
    /**
     Truncates the given text to a specified maximum number of characters.
     
     - Parameters:
     - text: The text to truncate.
     - Returns: The truncated text.
     */
    func truncateText(_ text: String) -> String {
        if text.count > maxCharacters {
            return String(text.prefix(maxCharacters)) + "..."
        } else {
            return text
        }
    }
    
    /**
     Removes a movie from the log, updating the `movies` array and CoreData model.
     
     - Parameters:
     - movieId: The id of the movie to remove.
     */
    func removeMovie(movieId: Int) {
        if let index = movies.firstIndex(where: { $0.0.id == movieId }) {
            movies.remove(at: index)
            
            // Update log object
            switch (log) {
            case .log(let log):
                // Update Firebase
                DispatchQueue.main.async { [self] in
                    Task {
                        guard (fb.getUserId()) != nil, let logId = log.logId else {
                            return
                        }
                        do {
                            _ = try await logRepo.updateLog(logId: logId, updateData: ["movie_ids": movies.compactMap { String($0.0.id ?? 0) }]).get()
                        } catch {
                            print("Error updating movie order in Firebase: \(error.localizedDescription)")
                        }
                    }
                }
            case .localLog(let localLog):
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
    }
    
    /**
     Updates the name of the log.
     
     - Parameters:
     - newName: The new name for the log.
     */
    func updateLogName(newName: String) {
        switch (log) {
        case .log(let log):
            // Update Firebase
            DispatchQueue.main.async { [self] in
                Task {
                    guard (fb.getUserId()) != nil, let logId = log.logId else {
                        return
                    }
                    do {
                        _ = try await logRepo.updateLog(logId: logId, updateData: ["name": newName]).get()
                    } catch {
                        print("Error updating log name in Firebase: \(error.localizedDescription)")
                    }
                }
            }
        case .localLog(let localLog):
            localLog.name = newName
            do {
                try viewContext.save()
            } catch {
                print("Error saving updated log name: \(error.localizedDescription)")
            }
        }
    }
    
    /**
     Deletes a draft movie from the log.
     
     - Parameters:
     - movies: The array of movies.
     - offsets: The index set of the movie to delete.
     - Returns: The updated array of movies after deletion.
     */
    func deleteDraftMovie(movies: [(MovieData, String)], at offsets: IndexSet) -> [(MovieData, String)] {
        var newMovies = movies
        newMovies.remove(atOffsets: offsets)
        return newMovies
    }
    
    /**
     Moves draft movies within the log.
     
     - Parameters:
     - movies: The array of movies.
     - source: The source index set.
     - offsets: The destination index.
     - Returns: The updated array of movies after moving.
     */
    func moveDraftMovies(movies: [(MovieData, String)], from source: IndexSet, to destination: Int) -> [(MovieData, String)] {
        var newMovies = movies
        newMovies.move(fromOffsets: source, toOffset: destination)
        return newMovies
    }
    
    /**
     Saves changes to the log, including its name and movie list.
     
     - Parameters:
     - movies: The array of movies.
     - draftLogName: The draft name for the log.
     */
    func saveChanges(draftLogName: String, movies: [(MovieData, String)], watchedMovies: [(MovieData, String)]) {
        // Apply changes from draft state to the view model
        if (!draftLogName.isEmpty) {
            updateLogName(newName: draftLogName)
        }
        
        // Update view model
        self.movies = movies
        
        // Update log object
        switch (log) {
        case .log(let log):
            // Update Firebase
            DispatchQueue.main.async { [self] in
                Task {
                    guard (fb.getUserId()) != nil, let logId = log.logId else {
                        return
                    }
                    do {
                        _ = try await logRepo.updateLog(
                            logId: logId,
                            updateData: ["movie_ids": movies.compactMap { String($0.0.id ?? 0) }, "watched_ids": watchedMovies.compactMap { String($0.0.id ?? 0) }]
                        ).get()
                    } catch {
                        print("Error updating movie order in Firebase: \(error.localizedDescription)")
                    }
                }
            }
        case .localLog(let localLog):
            var updatedMovieArray: [LocalMovieData] = []
            var updatedWatchedArray: [LocalMovieData] = []
            
            // Unwatched Movies
            for (index, e) in movies.enumerated() {
                let movieData = LocalMovieData(context: self.viewContext)
                movieData.movie_id = String(e.0.id ?? 0)
                movieData.movie_index = Int64(index)
                updatedMovieArray.append(movieData)
            }
            
            // Watched Movies
            for (index, e) in watchedMovies.enumerated() {
                let movieData = LocalMovieData(context: self.viewContext)
                movieData.movie_id = String(e.0.id ?? 0)
                movieData.movie_index = Int64(index)
                updatedWatchedArray.append(movieData)
            }
            
            localLog.movie_ids = NSSet(array: updatedMovieArray)
            localLog.watched_ids = NSSet(array: updatedWatchedArray)
            do {
                try viewContext.save()
            } catch {
                print("Error saving changes to Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    func shuffleUnwatchedMovies() {
        switch (log) {
        case .log(let log):
            // Update Firebase
            DispatchQueue.main.async { [self] in
                Task {
                    guard (fb.getUserId()) != nil, let logId = log.logId else {
                        return
                    }
                    do {
                        self.movies.shuffle()
                        let shuffledArray = movies.compactMap { String($0.0.id ?? 11) }
                        _ = try await logRepo.updateLog(logId: logId, updateData: ["movie_ids": shuffledArray]).get()
                    } catch {
                        print("Error updating movie order in Firebase: \(error.localizedDescription)")
                    }
                }
            }
        case .localLog(let localLog):
            guard let unwatchedMoviesSet = localLog.movie_ids as? Set<LocalMovieData> else { return }
            
            // Convert Set to Array to shuffle
            var unwatchedMoviesArray = Array(unwatchedMoviesSet)
            
            // Shuffle the array
            unwatchedMoviesArray.shuffle()
            
            for (newIndex, movie) in unwatchedMoviesArray.enumerated() {
                movie.movie_index = Int64(newIndex)
            }
            
            // Save Locally
            do {
                try viewContext.save()
                fetchMovies()
            } catch {
                print("Error shuffling unwatched movies in Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    func getUserId() -> String? {
        return fb.getUserId()
    }
    
    func getFriends() {
        guard case .log(_) = log else { return }
        DispatchQueue.main.async {
            Task {
                do {
                    guard let userId = self.getUserId() else {
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
    
    func getCollaborators() {
        guard case .log(let fbLog) = log else { return }
        DispatchQueue.main.async {
            Task {
                do {
                    guard let logId = fbLog.logId else {
                        return
                    }
                    let result = try await self.logRepo.getCollaborators(logId: logId).get()
                    self.collaborators = result
                } catch {
                    print("Error getting collaborators: \(error)")
                }
            }
        }
    }
    
    func updateCollaborators(collaborators: [String]) {
        guard case .log(let fbLog) = log else { return }
        DispatchQueue.main.async {
            Task {
                do {
                    guard let logId = fbLog.logId else {
                        return
                    }
                    
                    // Collaborators to add
                    var set1 = Set(collaborators)
                    var set2 = Set(self.collaborators.compactMap { $0.userId })
                    let addCollabs = Array(set1.subtracting(set2))
                    
                    // Collaborators to remove
                    set1 = Set(self.collaborators.compactMap { $0.userId })
                    set2 = Set(collaborators)
                    let removeCollabs = Array(set1.subtracting(set2))
                    
                    _ = try await self.logRepo.addCollaborators(logId: logId, collaborators: addCollabs).get()
                    
                    _ = try await self.logRepo.removeCollaborators(logId: logId, collaborators: removeCollabs).get()
                } catch {
                    print("Error updating collaborators: \(error)")
                }
            }
        }
    }
    
    func updateIsOwner() -> Bool {
        guard case .log(let fbLog) = log else { return true }
        return getUserId() == fbLog.owner?.userId
    }
    
    func updateIsCollaborator() -> Bool {
        guard case .log(let fbLog) = log else { return true }
        return fbLog.collaborators?.contains(getUserId() ?? "") ?? false
    }
    
    func isLocalLog() -> Bool {
        guard case .log(_) = log else { return true }
        return false
    }
    
    func getLogName() -> String {
        switch log {
        case .localLog(let log):
            return log.name ?? ""
        case .log(let log):
            return log.name ?? ""
        }
    }
    
    func getCollaboratorAvatars() -> [String] {
        guard case .log(_) = log else { return [] }
        var avatars = [getAvatarId(avatarPreset: ownerData?.avatarPreset ?? 1)]
        avatars.append(contentsOf: collaborators.map { getAvatarId(avatarPreset: $0.avatarPreset ?? 1) })
        return avatars
    }
    
    func getOwnerData() {
        guard case .log(let fbLog) = log else { return }
        DispatchQueue.main.async {
            Task {
                do {
                    guard let userId = fbLog.owner?.userId else {
                        return
                    }
                    
                    self.ownerData = try await self.userRepo.getUser(userId: userId).get()
                } catch {
                    print("Error updating owner data: \(error)")
                }
            }
        }
    }
    
    func canSwipeToMarkWatchedUnwatched() -> Bool {
        switch log {
        case .localLog:
            return true
        case .log:
            return updateIsOwner() || updateIsCollaborator()
        }
    }
    
    private func initLogListener() {
        guard case .log(let fbLog) = log else { return }
        guard let logId = fbLog.logId else { return }
        logListener = fb.getCollectionRef(refName: "logs")?.document(logId)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
            
                if document.exists {
                    do {
                        let logData = try document.data(as: LogData.self)
                        self.log = LogType.log(logData)
                        
                        // Check if still owner or collaborator
                        self.isOwner = self.updateIsOwner()
                        self.isCollaborator = self.updateIsCollaborator()
                        
                        // Update collaborators
                        self.getCollaborators()
                        
                        self.fetchMovies()
                    } catch {
                        print("Failed to decode document")
                        return
                    }
                } else {
                    // Document was likely deleted
                    self.isOwner = false
                    self.isCollaborator = false
                    self.logDeleted = true
                    
                    let logData = LogData()
                    self.log = LogType.log(logData)
                    print("Document was deleted")
                }
          }
    }
    
    private func removeListener() {
        logListener?.remove()
    }
    
    func updateLogVisibility(isVisible: Bool) {
        guard case .log(let fbLog) = log, let logId = fbLog.logId else { return }
        
        Task {
            do {
                _ = try await logRepo.updateLog(logId: logId, updateData: ["is_visible": isVisible]).get()
            } catch {
                print("Error updating log visibility: \(error.localizedDescription)")
            }
        }
    }

}

