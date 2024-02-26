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
        }
        .navigationTitle(searchText.isEmpty ? "Add Movies" : "Results")
        .navigationBarTitleDisplayMode(.large)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search for a movie", text: $searchText)
                .onChange(of: searchText) { newValue in
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
            NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0)), tag: String(movie.id ?? 0), selection: $selectedMovieId) {
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
                    addButton(for: movie) // This button might need adjustments to not interfere with navigation
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
        Button(action: {
            // Call the method to add the movie directly to the log
            viewModel.addMovieToLog(movieId: String(movie.id ?? 0), log: log)
        }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color(hex: "#3891e1"))
                .imageScale(.large)
        }
        .padding()
    }
}


