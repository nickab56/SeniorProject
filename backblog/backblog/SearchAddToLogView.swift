//
//  SearchAddToLogView.swift
//  backblog
//
//  Created by Nick Abegg on 2/23/24.
//

import SwiftUI

struct SearchAddToLogView: View {
    @StateObject private var viewModel = SearchViewModel(fb: FirebaseService(), movieService: MovieService())
    @State private var searchText = ""
    var log: LogType // The log to which movies will be added
    @State private var selectedMovieId: String?
    
    @State private var showingAlreadyInLogNotification = false
    @State private var showingMovieAddedNotification = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading) {
                    searchField
                    movieList
                }
            }
            if showingAlreadyInLogNotification {
                NotificationView(text: "Movie already in log")
                            .transition(.move(edge: .bottom))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 375)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showingAlreadyInLogNotification = false
                                    }
                                }
                            }
                    }
            if showingMovieAddedNotification {
                NotificationView(text: "Movie added to log")
                    .transition(.move(edge: .bottom))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 375)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showingMovieAddedNotification = false 
                            }
                        }
                    }
            }

        }
        .navigationTitle(searchText.isEmpty ? "Add Movies" : "Results")
        .navigationBarTitleDisplayMode(.large)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search for a movie", text: $searchText)
                .onChange(of: searchText) { newValue, oldValue in
                    viewModel.searchMovies(query: newValue)
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var movieList: some View {
        ForEach(viewModel.movies, id: \.id) { movie in
            NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0), isComingFromLog: true, log: log), tag: String(movie.id ?? 0), selection: $selectedMovieId) {
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
            }
            .buttonStyle(PlainButtonStyle())
        }
    }


    private func movieImageView(for movieId: Int?) -> some View {
        Group {
            if let movieId = movieId, let halfSheetUrl = viewModel.halfSheetImageUrls[movieId], let url = halfSheetUrl {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 180, height: 100)
                .cornerRadius(8)
                .padding(.leading)
            } else {
                Color.gray
                    .frame(width: 180, height: 100)
                    .cornerRadius(8)
                    .padding(.leading)
                    .onAppear {
                        viewModel.loadHalfSheetImage(movieId: movieId ?? 0)
                    }
            }
        }
    }

    private func addButton(for movie: MovieSearchData.MovieSearchResult) -> some View {
        let isMovieAdded = viewModel.isMovieInLog(movieId: String(movie.id ?? 0), log: log)
        return Button(action: {
            if isMovieAdded {
                withAnimation {
                    showingAlreadyInLogNotification = true
                }
            } else {
                viewModel.addMovieToLog(movieId: String(movie.id ?? 0), log: log)
                withAnimation {
                    showingMovieAddedNotification = true // Show "Movie added to log" notification
                }
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(isMovieAdded ? .gray : Color(hex: "#3891e1"))
                .imageScale(.large)
        }
        .padding()
    }



    
    struct NotificationView: View {
        let text: String
        
        var body: some View {
            Text(text)
                .padding()
                .background(Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .zIndex(1)
        }
    }

}


