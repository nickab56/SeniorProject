//
//  MoviesViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import Foundation

class MoviesViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var movieData: MovieData?
    @Published var errorMessage: String?
    
    var movieId: String
    
    private var fb: FirebaseProtocol
    private var movieService: MovieService
    
    private var moviesRepo: MovieRepository
    
    init(movieId: String, fb: FirebaseProtocol, movieService: MovieService) {
        self.movieId = movieId
        self.moviesRepo = MovieRepository(fb: fb, movieService: movieService)
        self.fb = fb
        self.movieService = movieService
    }
    
    // fetches the movie details using the id using repo function.
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
    
    func formatReleaseYear(from dateString: String?) -> String {
        guard let dateString = dateString, let year = dateString.split(separator: "-").first else {
            return "Unknown year"
        }
        return String(year)
    }
    
}
