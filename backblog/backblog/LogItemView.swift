import SwiftUI

enum LogType {
    case localLog(LocalLogData)
    case log(LogData)
}

struct LogItemView: View {
    let log: LogType
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
                            .overlay(Rectangle().foregroundColor(.black).opacity(0.3))
                    case .failure:
                        Image("NewLogImage") // Use the local asset as a fallback
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 10)
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipped()
            } else {
                Image("NewLogImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 10)
            }

            VStack {
                let txt = switch log {
                case .localLog(let local):
                    local.name ?? ""
                case .log(let log):
                    log.name ?? ""
                }
                Text(truncateText(txt))
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
        if (!logContainsMovies()) {
            isLoading = false
            return
        }
        
        guard let movieId: String = switch log {
        case .localLog(let local):
            (local.movie_ids?.allObjects.first as? LocalMovieData)?.movie_id
        case .log(let log):
            (log.movieIds?.keys.first)
        } else {
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
        return switch log {
        case .localLog(let local):
            local.movie_ids?.count ?? 0 > 0
        case .log(let log):
            log.movieIds?.keys.count ?? 0 > 0
        }
    }

    private func truncateText(_ text: String) -> String {
        if text.count > maxCharacters {
            return String(text.prefix(maxCharacters)) + "..."
        } else {
            return text
        }
    }
}
