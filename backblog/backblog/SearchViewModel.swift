//
//  SearchViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import Foundation
import FirebaseFirestore

/**
 ViewModel for handling search operations and managing movie data in the context of search.
 */
class SearchViewModel: ObservableObject {
    @Published var movies: [MovieSearchData.MovieSearchResult] = [] // The search results.
    @Published var halfSheetImageUrls: [Int: URL?] = [:] // URLs for half sheet images of movies.
    @Published var backdropImageUrls: [Int: URL?] = [:] // URLs for backdrop images of movies.
    @Published var errorMessage: String? = nil // Error messages, if any.

    private let viewContext = PersistenceController.shared.container.viewContext // Core Data context.
    
    private var fb: FirebaseProtocol // Firebase service interface.
    private var movieService: MovieProtocol // Movie service for API interactions.
    
    private let movieRepo: MovieRepository // Repository for movie data fetching.
    
    let logRepo = LogRepository(fb: FirebaseService())
    
    init(fb: FirebaseProtocol, movieService: MovieProtocol) {
        self.fb = fb
        self.movieService = movieService
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
    }
    
    /**
     Searches for movies based on a query string and updates the movies state.
     
     - Parameters:
         - query: The search query.
     */
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            movies = []
            return
        }
        Task {
            let result = await movieRepo.searchMovie(query: query, page: 1)
            DispatchQueue.main.async {
                switch result {
                case .success(let movieSearchData):
                    let sortedResults = movieSearchData.results?.sorted(by: {
                        $0.popularity ?? 0 > $1.popularity ?? 0
                    }) ?? []
                    self.movies = sortedResults
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /**
     Searches for movies based on a genreId and updates the movies state.
     
     - Parameters:
         - query: The search query.
     */
    func searchMoviesByGenre(genreId: String) {
        Task {
            let result = await movieRepo.getMoviesByGenre(genreId: genreId)
            DispatchQueue.main.async {
                switch result {
                case .success(let movieSearchData):
                    let sortedResults = movieSearchData.results?.sorted(by: {
                        $0.voteAverage ?? 0 > $1.voteAverage ?? 0
                    }) ?? []
                    self.movies = sortedResults
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }


    /**
     Fetches and stores the URL for a movie's half sheet image.
     
     - Parameters:
         - movieId: The id of the movie for which the image is fetched.
     */
    func loadHalfSheetImage(movieId: Int) {
        Task {
            let result = await movieRepo.getMovieHalfSheet(movieId: String(movieId))
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let halfsheetPath):
                    if !halfsheetPath.isEmpty {
                        halfSheetImageUrls[movieId] = URL(string: "https://image.tmdb.org/t/p/w500" + halfsheetPath)
                    } else {
                        halfSheetImageUrls[movieId] = nil // Explicitly store nil for no image
                    }
                case .failure:
                    halfSheetImageUrls[movieId] = nil // Store nil on failure to indicate no image
                }
            }
        }
    }
    
    /**
     Fetches and stores the URL for a movie's backdrop image.
     
     - Parameters:
         - movieId: The id of the movie for which the backdrop image is fetched.
     */
    func loadBackdropImage(movieId: Int) {
        Task {
            let result = await movieRepo.getMovieById(movieId: String(movieId))
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let movieData):
                    if let backdropPath = movieData.backdropPath, !backdropPath.isEmpty {
                        backdropImageUrls[movieId] = URL(string: "https://image.tmdb.org/t/p/w1280" + backdropPath)
                    } else {
                        backdropImageUrls[movieId] = nil // Explicitly store nil for no image
                    }
                case .failure:
                    backdropImageUrls[movieId] = nil // Store nil on failure to indicate no image
                }
            }
        }
    }

    
    /**
     Adds a movie to a specified log, handling both Firebase and local logs.
     
     - Parameters:
         - movieId: The id of the movie to add.
         - log: The log to which the movie is added.
     */
    func addMovieToLog(movieId: String, log: LogType) {
        switch log {
        case .log(let fbLog):
            guard let logId = fbLog.logId else { return }

            // Determine if the movie is in watchedIds
            if fbLog.watchedIds?.contains(movieId) == true {
                // Prepare updates for moving from watchedIds to movieIds
                let updates: [String: Any] = [
                    "watched_ids": FieldValue.arrayRemove([movieId]),
                    "movie_ids": FieldValue.arrayUnion([movieId])
                ]
                
                // Perform the update
                Task {
                    let updateResult = await logRepo.updateLog(logId: logId, updateData: updates)
                    
                    switch updateResult {
                    case .success:
                        print("Movie added to unwatched!")
                    case .failure(let error):
                        print("Error moving movie from watched to movie list: \(error)")
                    }
                }
            } else {
                guard let logId = fbLog.logId else { return }
                
                Task {
                    let result = await movieRepo.addMovie(logId: logId, movieId: movieId)
                    
                    switch result {
                    case .success:
                        print("Movie added successfully to the log")
                    case .failure(let error):
                        print("Error adding movie to the log: \(error.localizedDescription)")
                    }
                }
            }
        case .localLog(let localLog):
            // Check if the movie is already in watchedIds
            if let watchedMovies = localLog.watched_ids as? Set<LocalMovieData>, let movieToMove = watchedMovies.first(where: { $0.movie_id == movieId }) {
                // Move from watched to unwatched
                localLog.removeFromWatched_ids(movieToMove)
                movieToMove.movie_index = Int64(localLog.movie_ids?.count ?? 0) // adds it to the bottom of watched
                localLog.addToMovie_ids(movieToMove)
            } else {
                // Add new unwatched movie
                let newMovie = LocalMovieData(context: viewContext)
                newMovie.movie_id = movieId
                newMovie.movie_index = Int64(localLog.movie_ids?.count ?? 0) // adds it to the bottom of watched
                localLog.addToMovie_ids(newMovie)
            }

            // Save context
            do {
                try viewContext.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    func isMovieInLog(movieId: String, log: LogType) -> Bool {
        switch log {
        case .log(let fbLog):
            return fbLog.movieIds?.contains(movieId) ?? false
        case .localLog(let localLog):
            let movieIds = localLog.movie_ids?.allObjects as? [LocalMovieData] ?? []
            return movieIds.contains(where: { $0.movie_id == movieId })
        }
    }

    /**
     Formats the release year from a given date string.
     
     - Parameters:
         - dateString: The date string from which the year is extracted.
     
     - Returns: A string representing the release year.
     */
    func formatReleaseYear(from dateString: String?) -> String {
        guard let dateString = dateString, let year = dateString.split(separator: "-").first else {
            return "Unknown year"
        }
        return String(year)
    }
}
