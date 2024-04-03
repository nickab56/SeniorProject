//
//  MoviesViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//  Updated by Jake Buhite on 2/23/24.
//
//  Description: Manages movie data and fetches movie details from MovieRepository.
//

import Foundation

/**
 ViewModel for managing movie data and other state changes for the MovieDetailsView.
 */
class MoviesViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var movieData: MovieData?
    @Published var errorMessage: String?
    
    var movieId: String
    var isComingFromLog: Bool
    var log: LogType?
    
    var isInUnwatchlist: Bool { return false } // this var is not used in anything, so it is always marked as unwatched
    
    @Published var isInUnwatchedMovies: Bool = false
    @Published var isInWatchedMovies: Bool = false
    
    private var fb: FirebaseProtocol
    private var movieService: MovieProtocol
    
    private var moviesRepo: MovieRepository
    
    /**
     Initializes the MoviesViewModel with the provided parameters.
     
     - Parameters:
         - movieId: The id of the movie for which details are fetched from TMDB.
         - fb: The FirebaseProtocol for handling Firebase operations
         - movieService: The MovieService for handling interactions with TMDB.
     */
    init(movieId: String, isComingFromLog: Bool, log: LogType? = nil, fb: FirebaseProtocol, movieService: MovieProtocol) {
        self.movieId = movieId
        self.isComingFromLog = isComingFromLog
        self.log = log
        self.moviesRepo = MovieRepository(fb: fb, movieService: movieService)
        self.fb = fb
        self.movieService = movieService
        
        checkMovieStatus()
    }
    
    func checkMovieStatus() {
        guard let log = log else { return }
        
        switch log {
        case .log(let fbLog):
            self.isInUnwatchedMovies = fbLog.movieIds?.contains(movieId) ?? false
            self.isInWatchedMovies = fbLog.watchedIds?.contains(movieId) ?? false
        case .localLog(let localLog):
            // Assuming LocalLogData has appropriate methods or properties to check for movieId
            self.isInUnwatchedMovies = localLog.movie_ids?.contains(where: { ($0 as? LocalMovieData)?.movie_id == movieId }) ?? false
            self.isInWatchedMovies = localLog.watched_ids?.contains(where: { ($0 as? LocalMovieData)?.movie_id == movieId }) ?? false
        }
    }
    
    func moveMovieToWatched() {
        guard let log = log, isInUnwatchedMovies else { return }
        
        // needs implemented so the movie is moved to watched list
        
    }
    
    func moveMovieToUnwatched() {
        guard let log = log, isInWatchedMovies else { return }
        
        // needs implemented so the movie is moved to unwatched list
        
    }
    
    /**
     Fetches movie details using the provided movie id, updating the `movieData` and `errorMessage` properties.
     */
    func fetchMovieDetails() {
        isLoading = true
        Task {
            let result = await moviesRepo.getMovieById(movieId: movieId)
            DispatchQueue.main.async { [self] in
                isLoading = false
                switch result {
                case .success(let movieData):
                    self.movieData = movieData
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /**
     Formats the release year from the given date string.
     
     - Parameters:
         - dateString: The data string to extract the year from.
     
     - Returns: A formatted string representing the release year.
     */
    func formatReleaseYear(from dateString: String?) -> String {
        guard let dateString = dateString, let year = dateString.split(separator: "-").first else {
            return "Unknown year"
        }
        return String(year)
    }
    
}
