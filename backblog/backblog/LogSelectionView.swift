//
//  LogSelectionView.swift
//  backblog
//
//  Created by Nick Abegg on 1/25/24.
//

import SwiftUI

struct LogSelectionView: View {
    let selectedMovieId: Int
    @Binding var showingSheet: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.orderIndex, ascending: true)]) var logs: FetchedResults<LogEntity>
    @State private var showingNotification = false // State variable to control the notification visibility

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(logs) { log in
                        Button(action: {
                            addMovieToLog(movieId: selectedMovieId, log: log)
                        }) {
                            Text(log.logname ?? "Unknown Log")
                        }
                    }
                }
                .navigationBarTitle("Select Log", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    showingSheet = false
                })

                if showingNotification {
                    notificationView // Custom view for the notification
                        .transition(.move(edge: .bottom)) // Animation for sliding in/out
                        .zIndex(1) // Ensures the notification view is above other content
                }
            }
        }
    }

    private func addMovieToLog(movieId: Int, log: LogEntity) {
        let existingMovieIds = log.movieIds?.split(separator: ",").map(String.init) ?? []
        if existingMovieIds.contains("\(movieId)") {
            // Movie is already in the log, show notification
            withAnimation {
                showingNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Hide notification after 2 seconds
                    showingNotification = false
                }
            }
        } else {
            // Add movie to log
            let newMovieIds = (log.movieIds ?? "") + ",\(movieId)"
            log.movieIds = newMovieIds.trimmingCharacters(in: CharacterSet(charactersIn: ","))
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
            .padding(.bottom, 50) // Adjust padding as needed
            .transition(.move(edge: .bottom)) // Smooth transition for sliding in/out
    }
}
