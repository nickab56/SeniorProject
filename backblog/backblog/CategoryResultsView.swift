//
//  CategoryResultsView.swift
//  backblog
//
//  Created by Nick Abegg on 1/--/24.
//

import SwiftUI

/**
 A view for searching and adding movies to a specified log.
 */
struct CategoryResultsView: View {
    @ObservedObject var vm: SearchViewModel
    @State var selectedGenreId: String
    @State var selectedGenreName: String

    @State private var showingLogSelection = false
    @State private var selectedMovieForLog: MovieSearchData.MovieSearchResult?
    
    @State private var tappedMovieId: Int?

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading) {
                    movieList
                }
            }
        }
        .onChange(of: selectedMovieForLog) { newValue, oldValue in }
        .sheet(isPresented: $showingLogSelection, content: {
            if let selectedMovie = selectedMovieForLog {
                LogSelectionView(selectedMovieId: selectedMovie.id ?? 0, showingSheet: $showingLogSelection)
            }
        })
        .navigationTitle(selectedGenreName)
        .navigationBarTitleDisplayMode(.large)
        .onAppear(perform: { vm.searchMoviesByGenre(genreId: selectedGenreId) })
    }
    
    /**
     A list displaying search results, allowing movies to be added to the log.
     */
    private var movieList: some View {
        ForEach(vm.movies, id: \.id) { movie in
            NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0), isComingFromLog: false, log: nil)) {
                HStack {
                    movieImageView(for: movie.id)

                    VStack(alignment: .leading) {
                        Text(movie.title ?? "N/A")
                            .foregroundColor(.white)
                            .bold()
                            .accessibilityIdentifier("SearchMovieTitle")
                        Text(vm.formatReleaseYear(from: movie.releaseDate))
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

    
    // KNOWN BUG: Shows the static placeholder image FIRST, then shows the animated one if it is actually loading an image. Should first show the animated image and if there is an image show that and if there is no image it should show the static.
    
    /**
     Fetches and displays the movie's image.
     
     - Parameters:
         - movieId: The id of the movie for which the image is displayed.
     */
    private func movieImageView(for movieId: Int?) -> some View {
        Group {
            if let movieId = movieId {
                // Try to load the half sheet image if available
                if let halfSheetUrl = vm.halfSheetImageUrls[movieId], let url = halfSheetUrl {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        AnimatedPlaceholderView()
                    }
                    .frame(width: 180, height: 100)
                    .cornerRadius(8)
                    .padding(.leading)
                }
                // If no half sheet image, then try to load the backdrop image
                else if let backdropUrl = vm.backdropImageUrls[movieId], let url = backdropUrl {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        AnimatedPlaceholderView()
                    }
                    .frame(width: 180, height: 100)
                    .cornerRadius(8)
                    .padding(.leading)
                }
                // If neither is available, show the Static placeholder
                else {
                    StaticPlaceholderView()
                        .onAppear {
                            vm.loadHalfSheetImage(movieId: movieId)
                            vm.loadBackdropImage(movieId: movieId)
                        }
                }
            } else {
                // Show the animated placeholder if there's no movie ID
                StaticPlaceholderView()
            }
        }
    }




    /**
     A button for adding the selected movie to the log.
     
     - Parameters:
         - movie: The movie to be added to the log.
     */
    private func addButton(for movie: MovieSearchData.MovieSearchResult) -> some View {
        Button(action: {
            self.tappedMovieId = movie.id
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                self.selectedMovieForLog = movie
                self.showingLogSelection = true
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(Color(hex: "#3891e1"))
                .imageScale(.large)
                .scaleEffect(tappedMovieId == movie.id ? 1.2 : 1.0)
        }

        .padding()
        .accessibilityLabel("Add to Log")
        .accessibility(identifier: "AddToLogButton")
        .onChange(of: tappedMovieId) { newValue, oldValue in
            // Reset the animation after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut) {
                    self.tappedMovieId = nil
                }
            }
        }
    }
    
    
    struct AnimatedPlaceholderView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 180, height: 100)
                    .padding(.leading)
                    .padding(.trailing)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }

    struct StaticPlaceholderView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 180, height: 100)
                    .padding(.leading)

                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.white.opacity(0.7))
            }
        }
    }

}
