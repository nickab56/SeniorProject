import SwiftUI

struct LogItemView: View {
    let log: LocalLogData
    let maxCharacters = 20

    @State private var posterURL: URL?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                Rectangle()
                    .foregroundColor(.gray)
                    .aspectRatio(1, contentMode: .fill)
            } else if let posterURL = posterURL {
                AsyncImage(url: posterURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().foregroundColor(.gray)
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(Rectangle().foregroundColor(.black).opacity(0.3)) // Black overlay for all movies
                    case .failure:
                        Image("NewLogImage") // Use the local asset as a fallback
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 10) // Apply blur to the placeholder image
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipped()
            } else {
                Image("NewLogImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 10) // Apply blur to the placeholder image
            }

            VStack {
                Text(truncateText(log.name ?? ""))
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .cornerRadius(15)
        .onAppear {
            fetchMoviePoster()
        }
    }

    private func fetchMoviePoster() {
        guard logContainsMovies(), let firstMovie = log.movie_ids?.allObjects.first as? LocalMovieData, let movieId = firstMovie.movie_id else {
            isLoading = false
            return
        }

        Task {
            let result = await MovieService.shared.getMoviePoster(movieId: movieId)
            DispatchQueue.main.async {
                switch result {
                case .success(let posterPath):
                    if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                        self.posterURL = posterURL
                    }
                case .failure:
                    print("Failed to load movie poster")
                }
                isLoading = false
            }
        }
    }

    private func logContainsMovies() -> Bool {
        return log.movie_ids?.count ?? 0 > 0
    }

    private func truncateText(_ text: String) -> String {
        if text.count > maxCharacters {
            return String(text.prefix(maxCharacters)) + "..."
        } else {
            return text
        }
    }
}
