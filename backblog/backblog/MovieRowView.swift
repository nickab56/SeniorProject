//
//  MovieRowView.swift
//  backblog
//
//  Created by Nick Abegg on 1/19/24.
//

import SwiftUI

struct MovieRowView: View {
    let movie: Movie
    
    var body: some View {
        HStack {
            // Use the backdrop image, fallback to half_sheet if unavailable
            if let imagePath = movie.backdrop_path ?? movie.half_sheet,
               let url = URL(string: "https://image.tmdb.org/t/p/w500\(imagePath)") {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 100, height: 60)
                .cornerRadius(8)
            }

            Text(movie.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()

            Button(action: {
                // Handle Add action
            }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(Color("3891E1")) // Adjust color as needed
            }
        }
    }
}

