import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel(fb: FirebaseService(), movieService: MovieService())
    @State private var searchText = ""
    @State private var isSearching = false

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
        .onChange(of: selectedMovieForLog) { newValue, oldValue in }
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
                .onChange(of: searchText) { newValue, oldValue in
                    isSearching = !newValue.isEmpty
                    vm.searchMovies(query: newValue)
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
        ForEach(vm.movies, id: \.id) { movie in
            NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0), isComingFromLog: false, log: nil)) {
                HStack {
                    movieImageView(for: movie.id)

                    VStack(alignment: .leading) {
                        Text(movie.title ?? "N/A")
                            .foregroundColor(.white)
                            .bold()
                            .accessibilityIdentifier("SearchMovieTitle")
                        Text(vm.formatReleaseYear(from: movie.releaseDate))
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
            if let movieId = movieId {
                // First, try to load the half sheet image if available
                if let halfSheetUrl = vm.halfSheetImageUrls[movieId], let url = halfSheetUrl {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 180, height: 100)
                    .cornerRadius(8)
                    .padding(.leading)
                }
                // If no half sheet image, then try to load the backdrop image
                else if let backdropUrl = vm.backdropImageUrls[movieId], let url = backdropUrl {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 180, height: 100)
                    .cornerRadius(8)
                    .padding(.leading)
                }
                // If neither is available, show a gray placeholder
                else {
                    Color.gray
                        .frame(width: 180, height: 100)
                        .cornerRadius(8)
                        .padding(.leading)
                        .onAppear {
                            vm.loadHalfSheetImage(movieId: movieId)
                            vm.loadBackdropImage(movieId: movieId)
                        }
                }
            } else {
                Color.gray
                    .frame(width: 180, height: 100)
                    .cornerRadius(8)
                    .padding(.leading)
            }
        }
    }



    private func addButton(for movie: MovieSearchData.MovieSearchResult) -> some View {
        Button(action: {
            self.tappedMovieId = movie.id
            withAnimation(.easeInOut(duration: 0.2)) {
                self.selectedMovieForLog = movie
                self.showingLogSelection = true
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color(hex: "#3891e1"))
                .imageScale(.large)
                .scaleEffect(tappedMovieId == movie.id ? 1.2 : 1.0)
                .opacity(tappedMovieId == movie.id ? 0.5 : 1.0)
        }
        .padding()
        .accessibilityLabel("Add to Log")
        .accessibility(identifier: "AddToLogButton")
        .onChange(of: tappedMovieId) { newValue, oldValue in
            // Reset the animation after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut) {
                    self.tappedMovieId = nil
                }
            }
        }
    }
}
