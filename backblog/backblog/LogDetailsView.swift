import SwiftUI
import CoreData

struct LogDetailsView: View {
    let log: LogType
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var movies: [(MovieData, String)] = [] // Pair of MovieData and half-sheet URL
    @State private var showingWatchedNotification = false
    @State private var editCollaboratorSheet = false
    
    @State private var watchedMovies: [(MovieData, String)] = []
    
    @State private var showingDeleteConfirmation = false


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
                
                HStack {
                    Text("Unwatched: \(movies.count)")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()

                    Text("Watched: \(watchedMovies.count)")
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
                
                if movies.isEmpty && watchedMovies.isEmpty {
                    Text("No movies added to this log yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        if !movies.isEmpty {
                            Section(header: Text("Unwatched").foregroundColor(.white).accessibility(identifier: "UnwatchedSectionHeader")) {
                                ForEach(movies, id: \.0.id) { (movie, halfSheetPath) in
                                    MovieRow(movie: movie, halfSheetPath: halfSheetPath)
                                        .accessibility(identifier: "MovieRow_\(movie.title?.replacingOccurrences(of: " ", with: "") ?? "Unknown")")
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button {
                                                markMovieAsWatched(movieId: movie.id ?? 0)
                                            } label: {
                                                Label("Watched", systemImage: "checkmark.circle.fill")
                                            }
                                            .tint(.green)
                                        }
                                }
                            }
                        }

                        Section(header: Text("Watched").foregroundColor(.white).accessibility(identifier: "WatchedSectionHeader")) {
                            ForEach(watchedMovies, id: \.0.id) { (movie, halfSheetPath) in
                                MovieRow(movie: movie, halfSheetPath: halfSheetPath)
                                    .listRowBackground(Color.clear)
                                    .accessibility(identifier: "MovieRow_\(movie.title?.replacingOccurrences(of: " ", with: "") ?? "Unknown")")
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button {
                                            markMovieAsUnwatched(movieId: movie.id ?? 0)
                                        } label: {
                                            Label("Unwatched", systemImage: "arrow.uturn.backward.circle.fill")
                                        }
                                        .tint(.blue)
                                    }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                }

                    
                Button("Delete Log") {
                    showingDeleteConfirmation = true
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
        .alert(isPresented: $showingDeleteConfirmation) { // Confirmation alert
                    Alert(
                        title: Text("Delete Log"),
                        message: Text("Are you sure you want to permanently delete this log?"),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteLog()
                        },
                        secondaryButton: .cancel()
                    )
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
        guard case .localLog(let localLog) = log else { return }

        if let index = movies.firstIndex(where: { $0.0.id == movieId }) {
            let movieTuple = movies.remove(at: index)
            watchedMovies.append(movieTuple)

            // Update Core Data model
            if let movieEntity = (localLog.movie_ids as? Set<LocalMovieData>)?.first(where: { $0.movie_id == String(movieId) }) {
                localLog.removeFromMovie_ids(movieEntity)
                localLog.addToWatched_ids(movieEntity)

                do {
                    try viewContext.save()
                    showingWatchedNotification = true
                } catch {
                    print("Error updating watched status in Core Data: \(error.localizedDescription)")
                }
            }
        }
    }

    private func markMovieAsUnwatched(movieId: Int) {
        guard case .localLog(let localLog) = log else { return }

        // Find the movie in the watchedMovies list
        if let index = watchedMovies.firstIndex(where: { $0.0.id == movieId }) {
            let movieTuple = watchedMovies.remove(at: index)
            movies.append(movieTuple)

            // Update Core Data model
            if let movieEntity = (localLog.watched_ids as? Set<LocalMovieData>)?.first(where: { $0.movie_id == String(movieId) }) {
                localLog.removeFromWatched_ids(movieEntity)
                localLog.addToMovie_ids(movieEntity)

                do {
                    try viewContext.save()
                } catch {
                    print("Error updating unwatched status in Core Data: \(error.localizedDescription)")
                }
            }
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
                .accessibility(identifier: "AddedToWatchedSwiped")
        }
    }
    
    private func fetchMovies() {
        guard case .localLog(let localLog) = log else { return }

        // Clear existing data
        movies = []
        watchedMovies = []

        // Fetch unwatched movies
        if let unwatchedMovieEntities = localLog.movie_ids as? Set<LocalMovieData> {
            for movieEntity in unwatchedMovieEntities {
                Task {
                    await fetchMovieDetails(movieId: movieEntity.movie_id ?? "", isWatched: false)
                }
            }
        }

        // Fetch watched movies
        if let watchedMovieEntities = localLog.watched_ids as? Set<LocalMovieData> {
            for movieEntity in watchedMovieEntities {
                Task {
                    await fetchMovieDetails(movieId: movieEntity.movie_id ?? "", isWatched: true)
                }
            }
        }
    }

    
    private func fetchMovieDetails(movieId: String, isWatched: Bool) async {
        let movieDetailsResult = await MovieService.shared.getMovieByID(movieId: movieId)
        let halfSheetResult = await MovieService.shared.getMovieHalfSheet(movieId: movieId)

        await MainActor.run {
            switch (movieDetailsResult, halfSheetResult) {
            case (.success(let movieData), .success(let halfSheetPath)):
                let fullPath = "https://image.tmdb.org/t/p/w500\(halfSheetPath)"
                let movieTuple = (movieData, fullPath)
                if isWatched {
                    watchedMovies.append(movieTuple)
                } else {
                    movies.append(movieTuple)
                }
            case (.failure(let error), _), (_, .failure(let error)):
                print("Error fetching movie by ID or half-sheet: \(error.localizedDescription)")
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
                        guard (FirebaseService.shared.auth.currentUser?.uid) != nil else {
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
                        .accessibility(identifier: "LogDetailsMovieTitle")
                }
            }
            .padding(.vertical, 5)
        }
    }
}
