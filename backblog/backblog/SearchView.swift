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
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for a movie", text: $searchText)
                            .onChange(of: searchText) { _ in
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
                    
                    // Search results
                    if isSearching {
                        ForEach(movies, id: \.id) { movie in
                            Text(movie.title)
                                .foregroundColor(.white)
                                .padding()
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
                    self.movies = fetchedMovies
                    let _ = print("Good")
                case .failure(let error):
                    let _ = print(self.errorMessage = error.localizedDescription)
                    let _ = print("Not Good")
                }
            }
        }
    }
}
