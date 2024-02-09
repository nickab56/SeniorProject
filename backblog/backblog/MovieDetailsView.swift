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
                    // TODO: figure out how to not have the text not come in center but align on the left
                    VStack {
                        HStack {
                            if let posterPath = movie.posterPath, let url = URL(string: "https://image.tmdb.org/t/p/w500" + posterPath) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .accessibility(identifier: "moviePoster")
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 120, height: 175)
                                .cornerRadius(10)
                                .padding(.top)
                            }
                            VStack{
                                // Movie Title
                                Text(movie.title ?? "N/A")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .bold()
                                    .accessibility(identifier: "movieTitle")
                                
                                // Release Date
                                if let releaseDate = movie.releaseDate {
                                    Text("\(releaseDate)")
                                        .foregroundColor(.gray)
                                        .accessibility(identifier: "movieReleaseDate")
                                }
                                
                                // Runtime
                                if let runtime = movie.runtime {
                                    Text("\(runtime) minutes")
                                        .foregroundColor(.white)
                                        .padding(.bottom, 1)
                                        .accessibility(identifier: "movieRunTime")
                                }
                                
                                // Genres
                                // TODO: need to a way to make genres hashable so that we can put a circle around each of the genres to match figma.
                                if let genres = movie.genres, !genres.isEmpty {
                                    Text("Genres: " + genres.map { $0.name ?? "N/A" }.joined(separator: ", "))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 1)
                                }

                            }
                        }
                        
                        Button(action: {
                            // TODO: need to figure out how to depending on where you click if say watched or add to log
                        }) {
                            Text("Add to Log / Watch")
                                .foregroundColor(.white)
                        }
                        .frame(width: 350, height: 40)
                        .background(Color(hex: "3891E1"))
                        .cornerRadius(25)
                        .padding(.top, 5)

                        // Overview
                        Text(movie.overview ?? "No overview available.")
                            .foregroundColor(.white)
                            .padding()

                        
                        // Director
                        if let crew = movie.credits?.crew, let director = crew.first(where: { $0.job == "Director" }) {
                            Text("**Director:** \(director.name ?? "N/A")")
                                .foregroundColor(.white)
                                .padding(.bottom, 15)
                                .accessibility(identifier: "movieDirector")
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
                                .accessibility(identifier: "movieCast")
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
