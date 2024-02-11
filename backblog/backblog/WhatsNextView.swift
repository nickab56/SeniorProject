import SwiftUI
import CoreData

struct WhatsNextView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var log: LocalLogData  // Assuming you're passing the specific log for "What's Next"

    @State private var nextMovie: LocalMovieData?  // The next movie to watch
    @State private var movieTitle: String = "Loading..."
    @State private var movieDetails: String = "Loading details..."
    @State private var halfSheetImage: Image = Image("img_placeholder_poster")
    
    var logsViewModel: LogsViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("From \(log.name ?? "Unknown")")
                .font(.subheadline)
                .foregroundColor(.gray)
                .bold()
                .padding(.leading)
                .accessibility(identifier: "logNameText")

            halfSheetImage
                .resizable()
                .scaledToFit()
                .cornerRadius(15)
                .padding(.horizontal, 10)
                .accessibility(identifier: "logPosterImage")

            HStack {
                VStack(alignment: .leading) {
                    Text(movieTitle)
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                        .accessibility(identifier: "WhatsNextTitle")

                    Text(movieDetails)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                        .accessibilityIdentifier("WhatsNextDetails")
                }
                
                Spacer()

                Button(action: {
                    markMovieAsWatched()
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "#3891e1"))
                }
                .padding(.trailing, 20)
                .accessibility(identifier: "checkButton")
            }
            .padding(.horizontal)
        }
        .onAppear {
            loadNextUnwatchedMovie()
        }
    }

    private func loadNextUnwatchedMovie() {
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

    private func loadMovieDetails(movie: LocalMovieData) {
        guard let movieId = movie.movie_id else { return }
        
        Task {
            // Fetch movie details (adapt this part to your data fetching logic)
            let movieDetailsResult = await MovieService.shared.getMovieByID(movieId: movieId)
            if case .success(let movieData) = movieDetailsResult {
                DispatchQueue.main.async {
                    movieTitle = movieData.title ?? "Unknown Title"
                    let releaseYear = movieData.releaseDate?.prefix(4) ?? "Year Unknown"
                    movieDetails = "\(movieData.runtime ?? 0) min · \(releaseYear)"
                }

                // Fetch half-sheet image (adapt this part to your data fetching logic)
                let halfSheetResult = await MovieService.shared.getMovieHalfSheet(movieId: movieId)
                if case .success(let halfSheetPath) = halfSheetResult, let url = URL(string: "https://image.tmdb.org/t/p/w500\(halfSheetPath)") {
                    let _ = ImageLoader.loadImage(from: url) { image in
                        DispatchQueue.main.async {
                            halfSheetImage = Image(uiImage: image)
                        }
                    }
                }
            }
        }
    }

    private func markMovieAsWatched() {
        guard let movie = nextMovie else { return }

        withAnimation {
            log.removeFromMovie_ids(movie)
            log.addToWatched_ids(movie)

            do {
                try viewContext.save()
                loadNextUnwatchedMovie()  // Refresh the view to show the next unwatched movie
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
