import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var movies: [Movie] = []
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Search")
                        .font(.system(size: 32))
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for a movie", text: $searchText)
                            .onChange(of: searchText) {
                                isSearching = !searchText.isEmpty
                                searchMovies(query: searchText)
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .accessibility(identifier: "movieSearchTextField")
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Search results
                    if isSearching {
                        ForEach(movies, id: \.id) { movie in
                            HStack {
                                // Combine the base URL with the half-sheet path
                                if let halfSheetPath = movie.half_sheet, let url = URL(string: "https://image.tmdb.org/t/p/w500" + halfSheetPath) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 110, height: 75)
                                    .cornerRadius(8)
                                    .padding(.leading)
                                } else {
                                    // Placeholder in case there is no image URL
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 110, height: 75)
                                        .cornerRadius(8)
                                        .padding(.leading)
                                }

                                Text(movie.title)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                    }

                }
            }
        }
        // Handle any error messages
        if let errorMessage = errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
        }
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
