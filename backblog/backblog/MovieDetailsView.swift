//
//  MovieDetailsView.swift
//  backblog
//
//  Created by Nick Abegg
//
//  Description: Details page for movies. Utilizes Repository functions found in network file.
//  Fetches and displays all the info for a movie

import SwiftUI

struct MovieDetailsView: View {
    let movieId: String
    @State private var movieData: MovieData?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            // Content
            if isLoading {
                ProgressView("Loading...")
            } else if let movie = movieData {
                ScrollView {
                    VStack {
                        if let posterPath = movie.posterPath, let url = URL(string: "https://image.tmdb.org/t/p/w500" + posterPath) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 180, height: 270)
                            .cornerRadius(10)
                            .padding(.top)
                        }

                        // Movie Title
                        Text(movie.title ?? "N/A")
                            .font(.title)
                            .foregroundColor(.white)
                            .bold()
                            .padding()

                        // Release Date
                        if let releaseDate = movie.releaseDate {
                            Text("Release Date: \(releaseDate)")
                                .foregroundColor(.white)
                                .padding(.bottom, 1)
                        }

                        // Overview
                        Text(movie.overview ?? "No overview available.")
                            .foregroundColor(.white)
                            .padding()

                        // Genres
                        if let genres = movie.genres, !genres.isEmpty {
                            Text("Genres: " + genres.map { $0.name ?? "N/A" }.joined(separator: ", "))
                                .foregroundColor(.white)
                                .padding(.bottom, 1)
                        }

                        // Runtime
                        if let runtime = movie.runtime {
                            Text("Runtime: \(runtime) minutes")
                                .foregroundColor(.white)
                                .padding(.bottom, 1)
                        }

                        // Cast
                        if let cast = movie.credits?.cast, !cast.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Cast:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 1)
                                ForEach(cast.prefix(5), id: \.id) { castMember in
                                    Text(castMember.name ?? "N/A")
                                        .foregroundColor(.white)
                                        .padding(.bottom, 1)
                                }
                            }.padding()
                        }

                        // Director
                        if let crew = movie.credits?.crew, let director = crew.first(where: { $0.job == "Director" }) {
                            Text("Director: \(director.name ?? "N/A")")
                                .foregroundColor(.white)
                                .padding(.bottom, 15)
                        }
                    }
                }
            } else if errorMessage != nil {
                Text("Failed to load movie details.")
            }
        }
        .onAppear {
            fetchMovieDetails()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // fetches the movie details using the id using repo function.
    private func fetchMovieDetails() {
        isLoading = true
        Task {
            let result = await MovieRepository.getMovieById(movieId: movieId)
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let movieData):
                    self.movieData = movieData
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
