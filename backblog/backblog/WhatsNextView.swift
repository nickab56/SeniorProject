import SwiftUI
import CoreData

struct WhatsNextView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var movie: LocalMovieData
    
    @ObservedObject var logsViewModel: LogsViewModel

    @State private var movieTitle: String = "Loading..."
    @State private var movieDetails: String = "Loading details..."
    @State private var halfSheetImage: Image = Image("img_placeholder_poster")

    var body: some View {
        VStack(alignment: .leading) {
            Text("From \(movie.movie_ids?.name ?? "Unknown")")
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
        .onReceive(logsViewModel.$refreshTrigger) { _ in
            loadNextWatchMovie() // React to changes in LogsViewModel
        }
        .onAppear {
            loadNextWatchMovie()
        }
    }

    private func loadNextWatchMovie() {
        guard let movieId = movie.movie_id else {
            movieTitle = "No Movies"
            movieDetails = "Add movies to the log"
            return
        }

        Task {
            // Fetch movie details
            let movieDetailsResult = await MovieService.shared.getMovieByID(movieId: movieId)
            if case .success(let movieData) = movieDetailsResult {
                DispatchQueue.main.async {
                    movieTitle = movieData.title ?? "Unknown Title"
                    let releaseYear = movieData.releaseDate?.prefix(4) ?? "Year Unknown"
                    movieDetails = "\(movieData.runtime ?? 0) min · \(releaseYear)"
                }

                // Fetch halfsheet image
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
        // Update the movie's watched status in Core Data
        withAnimation {
            movie.watched_ids = movie.movie_ids // Assuming 'watched_ids' is where you track watched movies
            movie.in_log = false // Optionally update the 'in_log' status if needed

            do {
                try viewContext.save()
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
