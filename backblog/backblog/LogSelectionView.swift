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
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(logs) { log in
                        MultipleSelectionRow(title: log.name ?? "Unknown Log", isSelected: selectedLogs.contains(log.log_id)) {
                            if selectedLogs.contains(log.log_id) {
                                selectedLogs.remove(log.log_id)
                                logsWithDuplicates.remove(log.log_id) // Remove from duplicates if deselected
                            } else {
                                selectedLogs.insert(log.log_id)
                                checkForDuplicateAndNotify(logId: log.log_id) // Check for duplicates when a log is selected
                            }
                        }
                        .accessibility(identifier: log.name ?? "unknownLog")
                    }
                }
                .navigationBarTitle("Select Log", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    addMovieToSelectedLogs()
                    showingSheet = false
                }.disabled(!logsWithDuplicates.isEmpty)) // Disable "Done" if there are duplicates

                if showingNotification {
                    notificationView
                }
            }
        }
    }

    private func checkForDuplicateAndNotify(logId: Int64) {
        if let log = logs.first(where: { $0.log_id == logId }), let movieIds = log.movie_ids as? Set<LocalMovieData>, movieIds.map({ $0.movie_id }).contains("\(selectedMovieId)") {
            logsWithDuplicates.insert(logId) // Mark log as having a duplicate
            showingNotification = true // Show notification
        }
    }

    private func addMovieToSelectedLogs() {
        selectedLogs.forEach { logId in
            if let log = logs.first(where: { $0.log_id == logId }) {
                addMovieToLog(movieId: selectedMovieId, log: log)
            }
        }
    }
    
    private func addMovieToLog(movieId: Int, log: LocalLogData) {
        guard let movieIds = log.movie_ids as? Set<LocalMovieData> else {
            return
        }
        let existingMovieIds = movieIds.map { $0.movie_id }
        
        // Check if movie is already in the log
        if existingMovieIds.contains("\(movieId)") {
            withAnimation {
                showingNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showingNotification = false
                }
            }
        } else {
            // Add movie to log
            let newMovieData = LocalMovieData(context: viewContext)
            newMovieData.movie_id = String(movieId)
            
            log.addToMovie_ids(newMovieData)
            
            do {
                try viewContext.save()
                showingSheet = false
            } catch {
                print("Error saving movie to log: \(error)")
            }
        }
    }

    private var notificationView: some View {
        Text("Movie is already in log!")
            .padding()
            .foregroundColor(.white)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .padding(.bottom, 50)
            .transition(.move(edge: .bottom))
            .accessibility(identifier: "NotificationView")
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
