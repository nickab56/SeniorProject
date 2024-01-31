import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var movies: [MovieSearchData.MovieSearchResult] = []
    @State private var errorMessage: String?
    @State private var halfSheetImageUrls: [Int: URL?] = [:]

    @State private var showingLogSelection = false
    @State private var selectedMovieForLog: MovieSearchData.MovieSearchResult?
    
    @State private var tappedMovieId: Int?

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading) {
                    searchField

                    movieList
                }
            }
        }
        .onChange(of: selectedMovieForLog) { _ in }
        .sheet(isPresented: $showingLogSelection, content: {
            if let selectedMovie = selectedMovieForLog {
                LogSelectionView(selectedMovieId: selectedMovie.id ?? 0, showingSheet: $showingLogSelection)
            }
        })
        .navigationTitle(searchText.isEmpty ? "Search" : "Results")
        .navigationBarTitleDisplayMode(.large)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search for a movie", text: $searchText)
                .onChange(of: searchText) { newValue in
                    isSearching = !newValue.isEmpty
                    searchMovies(query: newValue)
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .accessibility(identifier: "movieSearchField")
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var movieList: some View {
        ForEach(movies, id: \.id) { movie in
            NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0))) {
                HStack {
                    movieImageView(for: movie.id)

                    VStack(alignment: .leading) {
                        Text(movie.title ?? "N/A")
                            .foregroundColor(.white)
                            .bold()
                        Text(formatReleaseYear(from: movie.releaseDate))
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }

                    Spacer()

                    addButton(for: movie)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func movieImageView(for movieId: Int?) -> some View {
        Group {
            if let movieId = movieId, let url = halfSheetImageUrls[movieId] {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 180, height: 100)
                .cornerRadius(8)
                .padding(.leading)
            } else {
                Color.gray
                    .frame(width: 180, height: 100)
                    .cornerRadius(8)
                    .padding(.leading)
                    .onAppear {
                        if let movieId = movieId, halfSheetImageUrls[movieId] == nil {
                            // Only load if not already attempted
                            loadHalfSheetImage(movieId: movieId)
                        }
                    }
            }
        }
    }

    private func addButton(for movie: MovieSearchData.MovieSearchResult) -> some View {
        Button(action: {
            self.tappedMovieId = movie.id // Set the tappedMovieId to this movie's ID
            withAnimation(.easeInOut(duration: 0.2)) {
                self.selectedMovieForLog = movie
                self.showingLogSelection = true
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color(hex: "#3891e1"))
                .imageScale(.large)
                .scaleEffect(tappedMovieId == movie.id ? 1.2 : 1.0) // Scale up the tapped button
                .opacity(tappedMovieId == movie.id ? 0.5 : 1.0) // Reduce opacity when tapped
        }
        .padding()
        .accessibilityLabel("Add to Log")
        .onChange(of: tappedMovieId) { _ in
            // Reset the animation after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut) {
                    self.tappedMovieId = nil
                }
            }
        }
    }

    private func searchMovies(query: String) {
        guard !query.isEmpty else {
            movies = []
            return
        }
        Task {
            let result = await MovieService.shared.searchMovie(query: query, includeAdult: false, language: "en", page: 1)
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


    private func loadHalfSheetImage(movieId: Int) {
        Task {
            let result = await MovieService.shared.getMovieHalfSheet(movieId: String(movieId))
            DispatchQueue.main.async {
                switch result {
                case .success(let halfsheetPath):
                    if !halfsheetPath.isEmpty {
                        self.halfSheetImageUrls[movieId] = URL(string: "https://image.tmdb.org/t/p/w500" + halfsheetPath)
                    } else {
                        self.halfSheetImageUrls[movieId] = nil // Explicitly store nil for no image
                    }
                case .failure:
                    self.halfSheetImageUrls[movieId] = nil // Store nil on failure to indicate no image
                }
            }
        }
    }
    
    private func formatReleaseYear(from dateString: String?) -> String {
        guard let dateString = dateString, let year = dateString.split(separator: "-").first else {
            return "Unknown year"
        }
        return String(year)
    }

}
