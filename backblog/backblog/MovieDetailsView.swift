//
//  MovieDetailsView.swift
//  backblog
//
//  Created by Nick Abegg
//  Updated by Jake Buhite on 02/23/24.
//
//  Description: Details page for movies. Utilizes Repository functions found in network file.
//  Fetches and displays all the info for a movie
//

import SwiftUI

/**
 View displaying detailed information for a specific movie.
 
 - Parameters:
     - vm: The MoviesViewModel responsible for managing movie data.
 */
struct MovieDetailsView: View {
    @StateObject var vm: MoviesViewModel
    @State private var opacity: Double = 0
    @State private var blurAmount: CGFloat = 0
    @State private var showingLogSelection = false
    
    /**
     Initializes the MovieDetailsView with the provided movie Id.
     
     - Parameters:
         - movieId: The id of the movie in TMDB's database.
     */
    init (movieId: String, isComingFromLog: Bool, log: LogType?) {
        _vm = StateObject(wrappedValue: MoviesViewModel(movieId: movieId, isComingFromLog: isComingFromLog, log: log, fb: FirebaseService(), movieService: MovieService()))
    }

    /**
     The body of the MovieDetailsView, displaying movie details.
     */
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            // Content
            if vm.isLoading {
                ProgressView("Loading...")
            } else if let movie = vm.movieData {
                if let backdropPath = movie.backdropPath, let url = URL(string: "https://image.tmdb.org/t/p/w1280" + backdropPath) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .clipped()
                    .padding(.top, 100)
                    .frame(height: 100)
                    .edgesIgnoringSafeArea(.top)
                }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
                    .opacity(self.opacity)
                
                ScrollView {
                    
                    GeometryReader { geo in
                        Rectangle()
                            .frame(width: 0, height: 0)
                            .onAppear(perform: {
                                self.blurAmount = geo.frame(in: .global).midY
                            })
                            .onChange(of: geo.frame(in: .global).maxY) { _, midY in
                                self.opacity = (midY - blurAmount) / 100
                                
                            }
                    }
                    
                    // Inside the ScrollView, before the VStack
                    if movie.backdropPath == nil && movie.posterPath == nil {
                        Spacer(minLength: 100) // Adjust the length as needed
                    }
                    ZStack {
                        
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .edgesIgnoringSafeArea(.all)

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
                                        .padding(.leading, movie.posterPath == nil ? 20 : 0)
                                    
                                    // Release Date
                                    Text(vm.formatReleaseYear(from: movie.releaseDate))
                                        .foregroundColor(.white)
                                        .accessibility(identifier: "movieReleaseDate")
                                        .padding(.leading, movie.posterPath == nil ? 20 : 0)
                                    
                                    // Runtime
//                                    if let runtime = movie.runtime {
//                                        if runtime > 0 {
//                                            Text("\(runtime) minutes")
//                                                .foregroundColor(.white)
//                                                .accessibility(identifier: "movieRunTime")
//                                                .padding(.leading, movie.posterPath == nil ? 20 : 0)
//                                        } else {
//                                            Text("No Runtime Found")
//                                                .foregroundColor(.white)
//                                                .padding(.leading, movie.posterPath == nil ? 20 : 0)
//                                        }
//                                    }
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            if let genres = movie.genres, !genres.isEmpty {
                                                ForEach(genres, id: \.id) { genre in
                                                    Text(genre.name ?? "N/A")
                                                        .foregroundColor(.white)
                                                        .padding(7)
                                                        .background(Color.clear)
                                                        .overlay(
                                                            Capsule().stroke(Color.white, lineWidth: 1)
                                                        )
                                                }
                                            }
                                        }
                                        .padding(.vertical, 1)
                                    }
                                    .padding(.leading, 10)
                                    
                                }
                                .padding(.top, -60)
                            }
                            
                            
                            
                            
                            if vm.isComingFromLog {
                                if vm.isInUnwatchlist {
                                    Button(action: {
                                        //code to make movie to watched in log
                                    }) {
                                        Text("Add to Watched")
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 350, height: 40)
                                    .background(Color(hex: "3891E1"))
                                    .cornerRadius(25)
                                    .padding(.top, 5)
                                }
                        
                                else{
                                    Button(action: {
                                        //code to make movie to unwatch in log
                                    }) {
                                        Text("Reset to Unwatched")
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 350, height: 40)
                                    .background(Color(hex: "3891E1"))
                                    .cornerRadius(25)
                                    .padding(.top, 5)
                                }
                        }
                        else{
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
                        }
                            // TODO: Watch Providers
                            // Text(movie.watchProviders ?? "Not on streaming platform")
                            
                            
                            // Overview
                            Text(movie.overview ?? "No overview available.")
                                .foregroundColor(.white)
                                .padding(.bottom, 15)
                            
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
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack{
                                            ForEach(cast.prefix(5), id: \.id) { castMember in
                                                Text(castMember.name ?? "N/A")
                                                    .foregroundColor(.white)
                                                    .padding(.bottom, 1)
                                            }
                                        }
                                    }
                                }
                                .accessibility(identifier: "movieCast")
                            }
                        }
                        .padding()
                    }
                    .padding(.top, 100)
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


