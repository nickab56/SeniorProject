import SwiftUI
import CoreData

struct LogDetailsView: View {
    let log: LogType
    
    @State private var editCollaboratorSheet = false
    @StateObject var vm: LogViewModel
    
    init(log: LogType) {
        self.log = log
        _vm = StateObject(wrappedValue: LogViewModel(log: log))
    }


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
                    Text("Unwatched: \(vm.movies.count)")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()

                    Text("Watched: \(vm.watchedMovies.count)")
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
                
                if vm.movies.isEmpty && vm.watchedMovies.isEmpty {
                    Text("No movies added to this log yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        if !vm.movies.isEmpty {
                            Section(header: Text("Unwatched").foregroundColor(.white).accessibility(identifier: "UnwatchedSectionHeader")) {
                                ForEach(vm.movies, id: \.0.id) { (movie, halfSheetPath) in
                                    MovieRow(movie: movie, halfSheetPath: halfSheetPath)
                                        .accessibility(identifier: "MovieRow_\(movie.title?.replacingOccurrences(of: " ", with: "") ?? "Unknown")")
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button {
                                                vm.markMovieAsWatched(movieId: movie.id ?? 0)
                                            } label: {
                                                Label("Watched", systemImage: "checkmark.circle.fill")
                                            }
                                            .tint(.green)
                                        }
                                }
                            }
                        }

                        Section(header: Text("Watched").foregroundColor(.white).accessibility(identifier: "WatchedSectionHeader")) {
                            ForEach(vm.watchedMovies, id: \.0.id) { (movie, halfSheetPath) in
                                MovieRow(movie: movie, halfSheetPath: halfSheetPath)
                                    .listRowBackground(Color.clear)
                                    .accessibility(identifier: "MovieRow_\(movie.title?.replacingOccurrences(of: " ", with: "") ?? "Unknown")")
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button {
                                            vm.markMovieAsUnwatched(movieId: movie.id ?? 0)
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
                    vm.deleteLog()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
                .padding(.bottom, 20)
                .accessibility(identifier: "Delete Log")
            }
            if vm.showingWatchedNotification {
                WatchedNotificationView()
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                vm.showingWatchedNotification = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: vm.showingWatchedNotification)
        .onAppear {
            vm.fetchMovies()
        }
        .sheet(isPresented: $editCollaboratorSheet) {
            EditCollaboratorSheetView(isPresented: $editCollaboratorSheet)
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
