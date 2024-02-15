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
    @Published var nextMovie: LocalMovieData?  // The next movie to watch
    @Published var movieTitle: String = "Loading..."
    @Published var movieDetails: String = "Loading details..."
    @Published var halfSheetImage: Image = Image("img_placeholder_poster")
    
    private let fb = FirebaseService()
    private let movieService = MovieService()
    private let viewContext = PersistenceController.shared.container.viewContext
    
    let movieRepo: MovieRepository
    
    init() {
        self.movieRepo = MovieRepository(fb: fb, movieService: movieService)
    }
    
    func loadNextUnwatchedMovie(log: LocalLogData) {
        // Assuming movie_ids and watched_ids are Set<LocalMovieData>
        let unwatchedMovies = log.movie_ids as? Set<LocalMovieData> ?? Set()
        let watchedMovies = log.watched_ids as? Set<LocalMovieData> ?? Set()
        let nextUnwatchedMovie = unwatchedMovies.subtracting(watchedMovies).first

        nextMovie = nextUnwatchedMovie  // Update the state to reflect the next unwatched movie

        if let nextMovie = nextMovie {
            // Fetch and display movie details
            loadMovieDetails(movie: nextMovie)
        } else {
            // Handle case where there are no unwatched movies
            movieTitle = "All Caught Up!"
            movieDetails = "You've watched all the movies in this log."
            halfSheetImage = Image("default-placeholder") // Use an appropriate placeholder image
        }
    }

    func loadMovieDetails(movie: LocalMovieData) {
        guard let movieId = movie.movie_id else { return }
        
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
            log.removeFromMovie_ids(movie)
            log.addToWatched_ids(movie)

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

