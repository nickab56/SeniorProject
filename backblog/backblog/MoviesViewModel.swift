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
    
    var isInUnwatchlist: Bool {
            // Implement your logic here to check if the movie is in the unwatchlist
            // You might need to access some data or state to determine this
            // For example, you could check a list of unwatched movies
            // Return true if the movie is in the unwatchlist, otherwise false
            return false // Placeholder return value, replace it with your actual logic
        }
    
    private var fb: FirebaseProtocol
    private var movieService: MovieService
    
    private var moviesRepo: MovieRepository
    
    /**
     Initializes the MoviesViewModel with the provided parameters.
     
     - Parameters:
         - movieId: The id of the movie for which details are fetched from TMDB.
         - fb: The FirebaseProtocol for handling Firebase operations
         - movieService: The MovieService for handling interactions with TMDB.
     */
    init(movieId: String, isComingFromLog: Bool, log: LogType? = nil, fb: FirebaseProtocol, movieService: MovieService) {

        self.movieId = movieId
        self.isComingFromLog = isComingFromLog
        self.log = log
        self.moviesRepo = MovieRepository(fb: fb, movieService: movieService)
        self.fb = fb
        self.movieService = movieService
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
