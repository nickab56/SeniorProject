import SwiftUI
import CoreData

struct LogDetailsView: View {
    let log: LocalLogData
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var movies: [(MovieData, String)] = [] // Pair of MovieData and half-sheet URL

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Details for Log: \(log.name ?? "Unknown")")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()

                if movies.isEmpty {
                    Text("No movies added to this log yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(movies, id: \.0.id) { (movie, halfSheetPath) in
                            MovieRow(movie: movie, halfSheetPath: halfSheetPath)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        // Need Implement logic to mark the movie as watched
                                        print("Marked as watched")
                                    } label: {
                                        Label("Watched", systemImage: "checkmark.circle.fill")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                }

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
        guard let movieIds = log.movie_ids as? Set<LocalMovieData>, !(movieIds.count == 0) else { return }

        let movieIdArr = movieIds.map { $0.movie_id }

        movies = [] // Reset movies list

        for movieId in movieIdArr {
            guard let movieId = movieId else {
                continue
            }
            Task {
                let movieDetailsResult = await MovieService.shared.getMovieByID(movieId: movieId)
                let halfSheetResult = await MovieService.shared.getMovieHalfSheet(movieId: movieId)
                
                await MainActor.run {
                    switch (movieDetailsResult, halfSheetResult) {
                    case (.success(let movieData), .success(let halfSheetPath)):
                        let fullPath = "https://image.tmdb.org/t/p/w500\(halfSheetPath)"
                        self.movies.append((movieData, fullPath))
                    case (.failure(let error), _), (_, .failure(let error)):
                        print("Error fetching movie by ID or half-sheet: \(error.localizedDescription)")
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
    let halfSheetPath: String

    var body: some View {
        NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0))) {
            HStack {
                if let url = URL(string: halfSheetPath) {
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
}
