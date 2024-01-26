import SwiftUI

struct MovieDetailsView: View {
    let movie: Movie

    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            // Content
            ScrollView {
                VStack {
                    // Display movie half-sheet image
                    if let halfSheetPath = movie.half_sheet, let url = URL(string: "https://image.tmdb.org/t/p/w500" + halfSheetPath) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 330, height: 230)
                        .cornerRadius(10)
                        .padding(.top)
                    }

                    // Movie title
                    Text(movie.title)
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                        .padding()

                    // Other movie details
                    Text("Release Date: \(movie.release_date)")
                        .foregroundColor(.white)
                        .padding([.leading, .trailing])

                    Spacer()
                    
                    // Overview
                    HStack(alignment: .top) {
                        Text("Overview:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(movie.overview)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding([.leading, .trailing])

                    // Add other details as needed
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
