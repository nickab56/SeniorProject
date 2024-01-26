import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var movies: [Movie] = []
    @State private var errorMessage: String?
    
    @State private var showingLogSelection = false
    @State private var selectedMovieForLog: Movie?

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search for a movie", text: $searchText)
                            .onChange(of: searchText) { newValue in
                                searchMovies(query: newValue)
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    ForEach(movies, id: \.id) { movie in
                        NavigationLink(destination: MovieDetailsView(movie: movie)) {
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

                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(movie.release_date)
                                        .foregroundColor(.gray)
                                        .font(.footnote)
                                }

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
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .sheet(isPresented: $showingLogSelection) {
            if let selectedMovie = selectedMovieForLog {
                LogSelectionView(selectedMovieId: selectedMovie.id, showingSheet: $showingLogSelection)
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
        NetworkManager.shared.fetchMovies(searchQuery: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedMovies):
                    self.movies = fetchedMovies
                        .filter { $0.backdrop_path != nil && $0.half_sheet != nil }
                        .sorted { $0.popularity > $1.popularity }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
