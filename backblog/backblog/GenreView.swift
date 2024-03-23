//
//  GenreView.swift
//  backblog
//
//  Created by Nick Abegg on 3/23/24.
//

import SwiftUI

struct GenreView: View {
    let genre: String

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading) {
                    Text("\(genre) Movies")
                        .padding()
                        .bold()
                        .foregroundColor(.white)
                        .font(.title)
                    
                    // Loop through static movie data
                    ForEach(mockMovies, id: \.id) { movie in
                        HStack {
                            SearchView.StaticPlaceholderView() // Using the static placeholder
                                .frame(width: 180, height: 100)
                                .cornerRadius(8)
                                .padding(.leading)

                            VStack(alignment: .leading) {
                                Text(movie.title)
                                    .foregroundColor(.white)
                                    .bold()
                                    .accessibilityIdentifier("StaticMovieTitle")
                                Text(movie.releaseDate)
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }

                            Spacer()

                            // Static add button, functionality to be implemented
                            Button(action: {
                                // Add movie to log action
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(hex: "#3891e1"))
                                    .imageScale(.large)
                            }
                            .padding()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        //.navigationTitle("\(genre) Movies")
        .navigationBarTitleDisplayMode(.inline)
    }
}



// Simple movie data model for demonstration
struct StaticMovie {
    var id: Int
    var title: String
    var releaseDate: String
    var imageName: String
}

// Mock movie data
let mockMovies = [
    StaticMovie(id: 1, title: "Movie One", releaseDate: "2022", imageName: "moviePlaceholder"),
    StaticMovie(id: 2, title: "Movie Two", releaseDate: "2021", imageName: "moviePlaceholder"),
    StaticMovie(id: 3, title: "Movie Three", releaseDate: "2020", imageName: "moviePlaceholder")
]
