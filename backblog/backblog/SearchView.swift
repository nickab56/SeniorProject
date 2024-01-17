import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false

    let categories = ["Action", "Horror", "Sci-Fi", "Fantasy"]
    let movies = [
        ("The Batman (2022)", "img_placeholder_log_batman"),
        ("Everything Everywhere All at Once", "img_placeholder_log_batman"),
        ("Spider-Man Across the Spider-Verse", "img_placeholder_log_batman")
    ]

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
                            .onChange(of: searchText)
                            {
                            if (!searchText.isEmpty)
                                {
                                isSearching = true
                            }
                            else
                                {
                                isSearching = false
                            }
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Categories
                    if !isSearching {
                        categorySection
                    }

                    // Recently added by friends
                    if !isSearching {
                        recentlyAddedSection
                    }

                    // Search results (placeholder, replace with actual logic later)
                    if isSearching {
                        Text("Search results for \(searchText)")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
    }

    private var categorySection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(categories, id: \.self) { category in
                Button(action: {
                    // Category action
                }) {
                    VStack {
                        Image("img_placeholder_poster")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100)
                            .clipped()
                            .cornerRadius(8)
                        Text(category)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 150)
            }
        }
        .padding(.horizontal)
    }

    private var recentlyAddedSection: some View {
        VStack(alignment: .leading) {
            Text("Friends Recently Added")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(movies, id: \.0) { movie in
                    VStack {
                        Image(movie.1)
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity, alignment: .top)
                            .clipped()
                            .cornerRadius(8)
                        Text(movie.0)
                            .foregroundColor(.white)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
