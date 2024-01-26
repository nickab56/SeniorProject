import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var movies: [Movie] = []
    @State private var errorMessage: String?
    
    @State private var showingLogSelection = false
    @State private var selectedMovieForLog: Movie?

    var body: some View {
        NavigationView {
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
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        if isSearching {
                            ForEach(movies, id: \.id) { movie in
                                HStack {
                                    if let halfSheetPath = movie.half_sheet, let url = URL(string: "https://image.tmdb.org/t/p/w500" + halfSheetPath) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                        } placeholder: {
                                            Color.gray
                                        }
                                        .frame(width: 145, height: 90)
                                        .cornerRadius(8)
                                        .padding(.leading)
                                    }

                                    NavigationLink(destination: MovieDetailsView(movie: movie)) {
                                        Text(movie.title)
                                            .foregroundColor(.white)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    Spacer()

                                    Button(action: {
                                        self.selectedMovieForLog = movie
                                        self.showingLogSelection = true
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(Color(hex: "#3891e1"))
                                            .imageScale(.large)
                                    }
                                    .padding()
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingLogSelection) {
                if let selectedMovie = selectedMovieForLog {
                    LogSelectionView(selectedMovieId: selectedMovie.id, showingSheet: $showingLogSelection)
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }


    private func searchMovies(query: String) {
        guard !query.isEmpty else {
            movies = []
            return
        }
        NetworkManager.shared.fetchMovies(searchQuery: query) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let fetchedMovies):
                            // Filter out movies without a backdrop or a half-sheet
                            // and sort them by popularity in descending order
                            self.movies = fetchedMovies
                                .filter { $0.backdrop_path != nil && $0.half_sheet != nil }
                                .sorted { $0.popularity > $1.popularity }
                            let _ = print("Good")
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                            let _ = print("Not Good")
                }
            }
        }
    }
}
