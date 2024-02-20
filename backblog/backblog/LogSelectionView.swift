import SwiftUI

struct LogSelectionView: View {
    let selectedMovieId: Int
    @Binding var showingSheet: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LocalLogData.orderIndex, ascending: true)]) var logs: FetchedResults<LocalLogData>
    @State private var selectedLogs = Set<Int64>()
    @State private var logsWithDuplicates = Set<Int64>() // Track logs with duplicate movies
    @State private var showingNotification = false

    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section {
                        ForEach(logs) { log in
                            MultipleSelectionRow(title: log.name ?? "Unknown Log", isSelected: selectedLogs.contains(log.log_id)) {
                                                            handleLogSelection(logId: log.log_id)
                                                        }
                            .padding(.vertical, 5)
                        }
                    }

                    Section {
                        Button(action: {
                            if selectedLogs.isEmpty {
                                showingSheet = false // Consider how to handle new log creation
                            }
                            else {
                                addMovieToSelectedLogs()
                                showingSheet = false
                            }
                        }) {
                            Text(selectedLogs.isEmpty ? "New Log" : "Add")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .disabled(!logsWithDuplicates.isEmpty) // Disable "Done" if there are duplicates

                        Button(action: {
                            showingSheet = false
                        }) {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationBarTitle("Add to Log", displayMode: .inline)
            }

            if showingNotification {
                NotificationView()
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showingNotification = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: showingNotification)
        .preferredColorScheme(.dark)
    }

    private func handleLogSelection(logId: Int64) {
        if isDuplicateInLog(logId: logId) {
            // If the movie is already in the log, show notification and don't change selection
            withAnimation {
                showingNotification = true
            }
        } else {
            // If the movie is not in the log, toggle selection
            if selectedLogs.contains(logId) {
                selectedLogs.remove(logId)
            } else {
                selectedLogs.insert(logId)
            }
        }
    }

    private func isDuplicateInLog(logId: Int64) -> Bool {
        if let log = logs.first(where: { $0.log_id == logId }) {
            if let movieIds = log.movie_ids as? Set<LocalMovieData> { // Cast NSSet to Set<LocalMovieData>
                for movie in movieIds {
                    if movie.movie_id == String(selectedMovieId) {
                        return true // The movie is already in the log
                    }
                }
            }
        }
        return false // The movie is not in the log
    }


    private func addMovieToSelectedLogs() {
        selectedLogs.forEach { logId in
            if let log = logs.first(where: { $0.log_id == logId }) {
                addMovieToLog(movieId: selectedMovieId, log: log)
            }
        }
    }
    
    private func addMovieToLog(movieId: Int, log: LocalLogData) {
        let existingMovieIds = log.movie_ids ?? []
        
        // Check if movie is already in the log
        if !existingMovieIds.contains("\(movieId)") {
            // Add movie to log
            let newMovie = LocalMovieData(context: viewContext)
            newMovie.movie_id = String(movieId)
            newMovie.movie_index = Int64(existingMovieIds.count)
            
            log.addToMovie_ids(newMovie)
            
            do {
                try viewContext.save()
                showingSheet = false
            } catch {
                print("Error saving movie to log: \(error)")
            }
        }
    }
    struct NotificationView: View {
        var body: some View {
            Text("Movie is already in log")
                .padding()
                .background(Color.gray.opacity(0.9))
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .zIndex(1)
                .accessibility(identifier: "AlreadyInLogText")
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
        .foregroundColor(isSelected ? .blue : .primary)
        .accessibility(identifier: "MultipleSelectionRow_\(title)")
    }
}
