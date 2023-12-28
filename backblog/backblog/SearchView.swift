import SwiftUI

struct SearchView: View {
    @State private var searchText = ""

    let categories = ["Action", "Horror", "Sci-Fi", "Fantasy"]
    let movies = [
        ("The Batman (2022)", "img_placeholder_poster"),
        ("Everything Everywhere All at Once", "img_placeholder_poster"),
        ("Spider-Man Across the Spider-Verse", "img_placeholder_poster")
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            ScrollView {
                VStack(alignment: .leading) {

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray) // Magnifying glass color

                        TextField("Search for a movie", text: $searchText)
                            .font(.system(size: 18, weight: .bold)) // Make the font bigger and bolder
                            .foregroundColor(.primary) // Make the text color darker
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Category buttons in a grid with two items per row
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                // Category action
                            }) {
                                VStack {
                                    Image("img_placeholder_poster") // Using the specified placeholder image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                    Text(category)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(height: 150) // Set a fixed height for the buttons
                        }
                    }
                    .padding(.horizontal)

                    // Recently added by friends
                    Text("Friends Recently Added")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading)

                    // Movie posters in a grid with two items per row
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(movies, id: \.0) { movie in
                            VStack {
                                Image(movie.1) // Using the specified placeholder image
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
    }
}
