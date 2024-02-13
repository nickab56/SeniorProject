//
//  SearchViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var movies: [MovieSearchData.MovieSearchResult] = []
    @Published var halfSheetImageUrls: [Int: URL?] = [:]
    @Published var errorMessage: String? = nil
    
    private let fb = FirebaseService()
    private let movieService = MovieService()
    
    private let movieRepo: MovieRepository
    
    init() {
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
    }
    
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
    
    func formatReleaseYear(from dateString: String?) -> String {
        guard let dateString = dateString, let year = dateString.split(separator: "-").first else {
            return "Unknown year"
        }
        return String(year)
    }
}
