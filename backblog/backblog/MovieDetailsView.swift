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
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .top, endPoint: .bottom)
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
                
                ScrollView() {
                    
                    GeometryReader { geo in
                        Rectangle()
                            .frame(width: 0, height: 0)
                            .onAppear(perform: {
                                self.blurAmount = geo.frame(in: .global).midY
                            })
                            .onChange(of: geo.frame(in: .global).midY) { _, midY in
                                self.opacity = abs(midY - blurAmount) / 100
                                
                            }
                    }
                    
                    // Inside the ScrollView, before the VStack
                    if movie.backdropPath == nil && movie.posterPath == nil {
                        Spacer(minLength: 120) // Adjust the length as needed
                    }
                    ZStack {
                        
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading){
                                        if let posterPath = movie.posterPath, let url = URL(string: "https://image.tmdb.org/t/p/w500" + posterPath) {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                                    .accessibility(identifier: "moviePoster")
                                            } placeholder: {
                                                Color.gray
                                            }
                                            .frame(width: 120, height: 175)
                                            .cornerRadius(10)
                                        }
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
                                            .foregroundColor(Color(hex: "#9F9F9F"))
                                            .accessibility(identifier: "movieReleaseDate")
                                            .padding(.leading, movie.posterPath == nil ? 20 : 0)
                                            .font(.system(size: 18))
                                        
                                        // Runtime
                                        if let runtime = movie.runtime {
                                            if runtime > 0 {
                                                Text("\(runtime) minutes")
                                                    .foregroundColor(Color(hex: "#9F9F9F"))
                                                    .accessibility(identifier: "movieRunTime")
                                                    .padding(.leading, movie.posterPath == nil ? 20 : 0)
                                                    .font(.system(size: 18))
                                            } else {
                                                Text("No Runtime Found")
                                                    .foregroundColor(Color(hex: "#9F9F9F"))
                                                    .padding(.leading, movie.posterPath == nil ? 20 : 0)
                                                    .font(.system(size: 18))
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                    .padding(.leading, 10)
                                }
                                .padding(.top, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        if let genres = movie.genres, !genres.isEmpty {
                                            ForEach(genres, id: \.id) { genre in
                                                Text(genre.name ?? "N/A")
                                                    .foregroundColor(Color(hex: "#9F9F9F"))
                                                    .font(.system(size: 14))
                                                    .textCase(.uppercase)
                                                    .bold()
                                                    .padding(7)
                                                    .background(Color.clear)
                                                    .overlay(
                                                        Capsule().stroke(Color(hex: "#9F9F9F"), lineWidth: 2)
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.vertical, 1)
                                    .padding(.leading, 1)
                                }
                                .padding(.top, 10)
                                
                                HStack() {
                                    if vm.isComingFromLog {
                                        Button(action: {
                                            if vm.isInUnwatchedMovies {
                                                vm.moveMovieToWatched()
                                            } else if vm.isInWatchedMovies {
                                                vm.moveMovieToUnwatched()
                                            }
                                            HapticFeedbackManager.shared.triggerSelectionFeedback()
                                        }) {
                                            if (!vm.completed) {
                                                Text(vm.isInUnwatchedMovies ? "ADD TO WATCHED" : vm.isInWatchedMovies ? "ADD TO UNWATCHED" : "ADD TO LOG")
                                                    .foregroundColor(.white)
                                                    .bold()
                                            } else {
                                                Text("ADDED ✓")
                                                    .foregroundColor(.white)
                                                    .bold()
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color(hex: "3891E1"))
                                        .cornerRadius(25)
                                        .disabled(vm.completed)
                                    }
                                    else{
                                        Button(action: {
                                            self.showingLogSelection = true
                                            HapticFeedbackManager.shared.triggerImpactFeedback()
                                        }) {
                                            Text("ADD TO LOG")
                                                .foregroundColor(.white)
                                                .bold()
                                        }
                                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                        .frame(height: 50)
                                        .background(Color(hex: "3891E1"))
                                        .cornerRadius(25)
                                        //.padding(.top, 5)
                                        //.padding(.leading, 20)
                                    }
                                }
                                .padding(.top, 20)
                                
                                // Overview
                                Text("Plot Summary")
                                    .padding(.bottom, 2)
                                    .padding(.top, 50)
                                    .foregroundColor(Color(hex: "#9F9F9F"))
                                    .font(.system(size: 18))
                                    .bold()
                                
                                Text(movie.overview ?? "No overview available.")
                                    .foregroundColor(.white)
                                    .bold()
                                    .font(.system(size: 16))
                                
                                // Director
                                Text("Directors")
                                    .padding(.bottom, 2)
                                    .padding(.top, 10)
                                    .foregroundColor(Color(hex: "#9F9F9F"))
                                    .font(.system(size: 18))
                                    .bold()
                                if let crew = movie.credits?.crew, let director = crew.first(where: { $0.job == "Director" }) {
                                    Text(director.name ?? "N/A")
                                        .foregroundColor(.white)
                                        .bold()
                                        .accessibility(identifier: "movieDirector")
                                        .font(.system(size: 16))
                                }
                                
                                // Cast
                                Text("Cast")
                                    .padding(.bottom, 2)
                                    .padding(.top, 10)
                                    .foregroundColor(Color(hex: "#9F9F9F"))
                                    .font(.system(size: 18))
                                    .bold()
                                if let cast = movie.credits?.cast, !cast.isEmpty {
                                    let names = cast.prefix(3).map { $0.name ?? "N/A" }
                                    let commaSepNames = names.joined(separator: ", ")
                                    Text(commaSepNames)
                                        .foregroundColor(.white)
                                        .bold()
                                        .padding(.bottom, 50)
                                        .accessibility(identifier: "movieCast")
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .scrollClipDisabled()                    
                    .padding(.top, 95)
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


