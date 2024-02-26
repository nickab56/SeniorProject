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
    @Published var backdropImageUrls: [Int: URL?] = [:]
    @Published var errorMessage: String? = nil
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    private var fb: FirebaseProtocol
    private var movieService: MovieService
    
    private let movieRepo: MovieRepository
    
    init(fb: FirebaseProtocol, movieService: MovieService) {
        self.fb = fb
        self.movieService = movieService
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

    func addMovieToLog(movieId: String, log: LogType) {
        switch log {
        case .log(let fbLog):
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
        case .localLog(let localLog):
            // Create a new LocalMovieData object and add it to the localLog
            let newMovie = LocalMovieData(context: viewContext)
            newMovie.movie_id = movieId
            newMovie.movie_index = Int64(localLog.movie_ids?.count ?? 0)
            localLog.addToMovie_ids(newMovie)

            do {
                try viewContext.save()
                print("Movie added successfully to the local log")
            } catch {
                print("Error adding movie to the local log: \(error.localizedDescription)")
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
