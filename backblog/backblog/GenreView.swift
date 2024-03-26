//
//  GenreView.swift
//  backblog
//
//  Created by Nick Abegg on 3/23/24.
//

/*
 TO DO:
        - Add a new file for the view model for genre
        - Fix the image formatting for the genre movie item list
          so it is more like search view
        - Implement the add movie to log button
 */

import SwiftUI

struct GenreView: View {
    let genreId: Int
    let genreName: String

    @StateObject private var viewModel = GenreViewModel()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading) {
                    Text("\(genreName) Movies")
                        .padding()
                        .bold()
                        .foregroundColor(.white)
                        .font(.title)

                    ForEach(viewModel.movies, id: \.id) { movie in
                        NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0), isComingFromLog: false, log: nil)) {
                            HStack {
                                movieImageView(for: movie.id)

                                VStack(alignment: .leading) {
                                    Text(movie.title ?? "N/A")
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(viewModel.formatReleaseYear(from: movie.releaseDate))
                                        .foregroundColor(.gray)
                                        .font(.footnote)
                                }

                                Spacer()

                                addButton(for: movie)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            viewModel.loadMovies(forGenre: genreId)
        }
        .navigationTitle("\(genreName) Movies")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func movieImageView(for movieId: Int?) -> some View {
        Group {
            if let movieId = movieId, let url = URL(string: "https://image.tmdb.org/t/p/w500\(viewModel.movies.first(where: {$0.id == movieId})?.posterPath ?? "")") {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 150)
                .cornerRadius(8)
                .padding(.trailing, 10)
            } else {
                Image(systemName: "film")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 150)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
    }

    private func addButton(for movie: MovieSearchData.MovieSearchResult) -> some View {
        Button(action: {
            // Implement button
        }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color(hex: "#3891e1"))
                .imageScale(.large)
        }
        .padding(.leading)
    }
}

class GenreViewModel: ObservableObject {
    @Published var movies: [MovieSearchData.MovieSearchResult] = []

    private let movieService = MovieService()

    func loadMovies(forGenre genreId: Int) {
        Task {
            let result = await movieService.searchMovieByGenre(genreId: genreId)
            await MainActor.run {
                switch result {
                case .success(let searchResults):
                    self.movies = (searchResults.results ?? []).sorted(by: { $0.voteAverage ?? 0 > $1.voteAverage ?? 0 })
                case .failure(let error):
                    print("Error loading genre movies: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func formatReleaseYear(from dateString: String?) -> String {
        guard let dateString = dateString, let year = dateString.split(separator: "-").first else {
            return "Unknown year"
        }
        return String(year)
    }
}
