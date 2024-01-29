import SwiftUI
import CoreData

struct LogDetailsView: View {
    let log: LogEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var movies: [MovieData] = []

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Details for Log: \(log.logname ?? "Unknown")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        if movies.isEmpty {
                            Text("No movies added to this log yet.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(movies, id: \.id) { movie in
                                NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0))) {
                                    MovieRow(movie: movie)
                                }
                            }
                        }
                    }
                }
                .padding()

                Button("Delete Log") {
                    deleteLog()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
                .padding(.bottom, 20)
                .accessibility(identifier: "Delete Log")
            }
        }
        .onAppear {
            fetchMovies()
        }
    }

    private func fetchMovies() {
        guard let movieIdsString = log.movieIds, !movieIdsString.isEmpty else { return }
        let movieIds = movieIdsString.split(separator: ",").map { String($0) }

        movies = [] // Reset movies list

        for idString in movieIds {
            Task {
                let result = await MovieRepository.getMovieById(movieId: idString)
                DispatchQueue.main.async {
                    switch result {
                    case .success(let movieData):
                        self.movies.append(movieData)
                    case .failure(let error):
                        print("Error fetching movie by ID: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func deleteLog() {
        viewContext.delete(log)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting log: \(error.localizedDescription)")
        }
    }
}

struct MovieRow: View {
    let movie: MovieData

    var body: some View {
        HStack {
            if let backdropPath = movie.backdropPath, let url = URL(string: "https://image.tmdb.org/t/p/w500" + backdropPath) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 145, height: 90)
                .cornerRadius(8)
                .padding(.leading)
            }

            VStack(alignment: .leading) {
                Text(movie.title ?? "N/A")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
        .padding(.vertical, 5)
    }
}
