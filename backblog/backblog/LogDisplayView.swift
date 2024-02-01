import SwiftUI

struct LogDisplayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let log: LocalLogData

    @State private var movieTitle: String = "Loading..."
    @State private var movieDetails: String = "Loading details..."
    @State private var halfSheetImage: Image = Image("img_placeholder_poster")

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

                    Text(movieDetails)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                }
                
                Spacer()

                Button(action: {
                    // Action for the button
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
            loadNextWatchMovie()
        }
    }

    private func loadNextWatchMovie() {
        guard let firstMovieId = log.movie_ids?.allObjects.first as? LocalMovieData, let movieId = firstMovieId.movie_id else {
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
