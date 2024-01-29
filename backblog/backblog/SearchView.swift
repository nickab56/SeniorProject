import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var movies: [MovieSearchData.MovieSearchResult] = []
    @State private var errorMessage: String?
    
    @State private var showingLogSelection = false
    @State private var selectedMovieForLog: MovieSearchData.MovieSearchResult?

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search for a movie", text: $searchText)
                           .onChange(of: searchText) {
                               isSearching = !searchText.isEmpty
                               searchMovies(query: searchText)
                           }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .accessibility(identifier: "movieSearchField")
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    ForEach(movies, id: \.id) { movie in
                        NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0))) {
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
                                        .bold()
                                        .accessibility(label: Text(movie.title ?? "Unknown Movie"))
                                    Text(movie.releaseDate ?? "Unknown release date")
                                        .foregroundColor(.gray)
                                        .font(.footnote)
                                }

                                Spacer()

                                Button(action: {
                                    self.selectedMovieForLog = movie
                                    self.showingLogSelection = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color(hex: "#3891e1"))
                                        .imageScale(.large)
                                }
                                .padding()
                                .accessibilityLabel("Add to Log")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .sheet(isPresented: $showingLogSelection) {
            if let selectedMovie = selectedMovieForLog {
                LogSelectionView(selectedMovieId: selectedMovie.id ?? 0, showingSheet: $showingLogSelection)
            }
        }
        .navigationTitle(searchText.isEmpty ? "Search" : "Results")
        .navigationBarTitleDisplayMode(.large)
    }

    private func searchMovies(query: String) {
        guard !query.isEmpty else {
            movies = []
            return
        }
        Task {
            let result = await MovieRepository.searchMovie(query: query, page: 1)
            DispatchQueue.main.async {
                switch result {
                case .success(let movieSearchData):
                    self.movies = movieSearchData.results ?? []
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
