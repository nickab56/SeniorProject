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
    @StateObject var vm: MoviesViewModel
    @State private var blurAmount: CGFloat = 0
    @State private var showingLogSelection = false
    
    init (movieId: String) {
        _vm = StateObject(wrappedValue: MoviesViewModel(movieId: movieId, fb: FirebaseService(), movieService: MovieService()))
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            // Content
            if vm.isLoading {
                ProgressView("Loading...")
            } else if let movie = vm.movieData {
                ScrollView {
                    if let backdropPath = movie.backdropPath, let url = URL(string: "https://image.tmdb.org/t/p/w1280" + backdropPath) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray
                        }
                        .clipped()
                        .padding(.top, -100)
                        .frame(height: 100)
                        .edgesIgnoringSafeArea(.top)
                    }
                    VStack(alignment: .leading) {
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
                            VStack(alignment: .leading) {
                                // Movie Title
                                Text(movie.title ?? "N/A")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .bold()
                                    .accessibility(identifier: "movieTitle")
                                
                                // Release Date
                                Text(vm.formatReleaseYear(from: movie.releaseDate))
                                    .foregroundColor(.white)
                                    .accessibility(identifier: "movieReleaseDate")
                                
                                // Runtime
                                if let runtime = movie.runtime {
                                    Text("\(runtime) minutes")
                                        .foregroundColor(.white)
                                        .accessibility(identifier: "movieRunTime")
                                }

                            }
                            .padding(.top, -60)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) { // Horizontal scroll view without indicators
                            HStack(spacing: 10) { // HStack with spacing for genre bubbles
                                if let genres = movie.genres, !genres.isEmpty {
                                    ForEach(genres, id: \.id) { genre in
                                        Text(genre.name ?? "N/A")
                                            .foregroundColor(.white)
                                            .padding(7)
                                            .background(Color.clear) // Clear background
                                            .overlay(
                                                Capsule().stroke(Color.white, lineWidth: 1) // White border
                                            )
                                    }
                                }
                            }
                            .padding(.vertical, 1)
                        }
                        .padding(.leading, 10)
                        
                        Button(action: {
                            self.showingLogSelection = true
                        }) {
                            Text("Add to Log")
                                .foregroundColor(.white)
                        }
                        .frame(width: 350, height: 40)
                        .background(Color(hex: "3891E1"))
                        .cornerRadius(25)
                        .padding(.top, 5)
                        .padding(.leading, 20)

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
            } else if vm.errorMessage != nil {
                Text("Failed to load movie details.")
            }
        }
        .onAppear {
            vm.fetchMovieDetails()
        }
        .sheet(isPresented: $showingLogSelection, content: {
            if Int(vm.movieId) != nil {
                LogSelectionView(selectedMovieId: Int(vm.movieId)!, showingSheet: $showingLogSelection)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
    }
}
