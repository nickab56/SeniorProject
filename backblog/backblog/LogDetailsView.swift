import SwiftUI
import CoreData

struct LogDetailsView: View {
    let log: LogType
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var movies: [(MovieData, String)] = [] // Pair of MovieData and half-sheet URL
    @State private var showingWatchedNotification = false
    @State private var editCollaboratorSheet = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                let logName = switch log {
                case .localLog(let log):
                    log.name ?? ""
                case .log(let log):
                    log.name ?? ""
                }
                HStack{
                    Text("\(logName)")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                }
                
                HStack{
                    Text("\(movies.count) movies")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Spacer()
                }.padding(.top, -25)
                
                HStack {
                    Button(action: {
                        editCollaboratorSheet = true
                    }) {
                        Image(systemName: "person.badge.plus")
                            .padding()
                            .font(.system(size: 25))
                    }
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button(action: {
                        // waiting for functionailty
                    }) {
                        Image(systemName: "pencil")
                            .padding()
                            .font(.system(size: 25))
                    }
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button(action: {
                        // waiting for functionailty
                    }) {
                        Image(systemName: "shuffle")
                            .padding()
                            .font(.system(size: 25))
                    }
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button(action: {
                        // waiting for functionailty
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .padding()
                            .font(.system(size: 30))
                    }
                    .background(Color.clear)
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }.padding(.top, -20)
                
                if movies.isEmpty {
                    Text("No movies added to this log yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(movies, id: \.0.id) { (movie, halfSheetPath) in
                            MovieRow(movie: movie, halfSheetPath: halfSheetPath)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        markMovieAsWatched(movieId: movie.id ?? 0)
                                    } label: {
                                        Label("Watched", systemImage: "checkmark.circle.fill")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                }
                    

                Button("Delete Log") {
                    deleteLog()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
                .padding(.bottom, 20)
                .accessibility(identifier: "Delete Log")
            }
            if showingWatchedNotification {
                WatchedNotificationView()
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showingWatchedNotification = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: showingWatchedNotification)
        .onAppear {
            fetchMovies()
        }
        .sheet(isPresented: $editCollaboratorSheet) {
            EditCollaboratorSheetView(isPresented: $editCollaboratorSheet)
        }
    }
    
    private func markMovieAsWatched(movieId: Int) {
            // Implement logic to mark the movie as watched in your data model
            
            // Show "Movie added to watched" notification
            withAnimation {
                showingWatchedNotification = true
            }
        }
    
    struct WatchedNotificationView: View {
        var body: some View {
            Text("Movie added to watched")
                .padding()
                .background(Color.gray.opacity(0.9))
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .zIndex(1) // Ensure the notification view is always on top
        }
    }
    
    private func fetchMovies() {
        var movieArr: [String]
        switch log {
        case .localLog(let log):
            guard let movieIds = log.movie_ids as? Set<LocalMovieData> else { return }
            movieArr = localMovieDataMapping(movieSet: movieIds)
        case .log(let log):
            guard let movieIds: [String: Bool] = log.movieIds else { return }
            movieArr = movieIds.compactMap { $0.key }
        }
        
        if (movieArr.count == 0) {
            return
        }

        movies = [] // Reset movies list

        for movieId in movieArr {
            Task {
                let movieDetailsResult = await MovieService.shared.getMovieByID(movieId: movieId)
                let halfSheetResult = await MovieService.shared.getMovieHalfSheet(movieId: movieId)
                
                await MainActor.run {
                    switch (movieDetailsResult, halfSheetResult) {
                    case (.success(let movieData), .success(let halfSheetPath)):
                        let fullPath = "https://image.tmdb.org/t/p/w500\(halfSheetPath)"
                        self.movies.append((movieData, fullPath))
                    case (.failure(let error), _), (_, .failure(let error)):
                        print("Error fetching movie by ID or half-sheet: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func localMovieDataMapping(movieSet: Set<LocalMovieData>?) -> [String] {
        guard let movies: Set<LocalMovieData> = movieSet, !(movies.count == 0) else { return [] }
        
        return movies.compactMap { $0.movie_id  }
    }

    private func deleteLog() {
        do {
            switch log {
            case .localLog(let log):
                viewContext.delete(log)
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            case .log(let log):
                DispatchQueue.main.async {
                    Task {
                        guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                            return
                        }
                        do {
                            guard let logId = log.logId else { return }
                            _ = try await LogRepository.deleteLog(logId: logId).get()
                        } catch {
                            throw error
                        }
                    }
                }
            }
        } catch {
            print("Error deleting log: \(error.localizedDescription)")
        }
    }
}

struct MovieRow: View {
    let movie: MovieData
    let halfSheetPath: String

    var body: some View {
        NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0))) {
            HStack {
                if let url = URL(string: halfSheetPath) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 145, height: 90)
                    .cornerRadius(8)
                    .padding(.leading)
                }
                
                VStack(alignment: .leading) {
                    Text(movie.title ?? "N/A")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 5)
        }
    }
}
