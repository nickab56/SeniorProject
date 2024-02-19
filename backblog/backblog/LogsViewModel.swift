//
//  LogsViewModel.swift
//  backblog
//
//  Created by Nick Abegg on 2/4/24.
//

import Foundation
import SwiftUI

class LogsViewModel: ObservableObject {
    @Published var refreshTrigger: Bool = false
    
    // What's Next
    @Published var nextMovie: String?  // The next movie to watch
    @Published var movieTitle: String = "Loading..."
    @Published var movieDetails: String = "Loading details..."
    @Published var halfSheetImage: Image = Image("img_placeholder_poster")
    
    private var fb: FirebaseProtocol
    private var movieService: MovieService
    private let viewContext = PersistenceController.shared.container.viewContext
    
    let movieRepo: MovieRepository
    
    init(fb: FirebaseProtocol, movieService: MovieService) {
        self.fb = fb
        self.movieService = movieService
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
    }
    
    func loadNextUnwatchedMovie(log: LocalLogData) {
        let unwatchedMovies = log.movie_ids ?? []
        
        let nextUnwatchedMovie = unwatchedMovies.first

        nextMovie = nextUnwatchedMovie  // Update the state to reflect the next unwatched movie

        if let nextMovie = nextMovie {
            // Fetch and display movie details
            loadMovieDetails(movie: nextMovie)
        } else {
            // Handle case where there are no unwatched movies
            movieTitle = "All Caught Up!"
            movieDetails = "You've watched all the movies in this log."
        }
    }

    func loadMovieDetails(movie: String?) {
        guard let movieId = movie else { return }
        
        Task {
            // Fetch movie details (adapt this part to your data fetching logic)
            let movieDetailsResult = await movieRepo.getMovieById(movieId: movieId)
            if case .success(let movieData) = movieDetailsResult {
                DispatchQueue.main.async { [self] in
                    movieTitle = movieData.title ?? "Unknown Title"
                    let releaseYear = movieData.releaseDate?.prefix(4) ?? "Year Unknown"
                    movieDetails = "\(movieData.runtime ?? 0) min · \(releaseYear)"
                }

                // Fetch half-sheet image (adapt this part to your data fetching logic)
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

    func markMovieAsWatched(log: LocalLogData) {
        guard let movie = nextMovie else { return }

        withAnimation {
            // Add the movie to the watched list
            if log.watched_ids == nil {
                log.watched_ids = [movie]
            } else {
                log.watched_ids?.append(movie)
            }

            // Remove the movie from the unwatched list
            if let index = log.movie_ids?.firstIndex(of: movie) {
                log.movie_ids?.remove(at: index)
            }

            // Save changes to the data store
            do {
                try viewContext.save()
                loadNextUnwatchedMovie(log: log)  // Refresh the view to show the next unwatched movie
            } catch {
                print("Error marking movie as watched: \(error.localizedDescription)")
            }
        }
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

