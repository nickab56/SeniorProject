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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LocalLogData.orderIndex, ascending: true)]) var logs: FetchedResults<LocalLogData>
    @State private var showingNotification = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(logs) { log in
                        Button(action: {
                            addMovieToLog(movieId: selectedMovieId, log: log)
                        }) {
                            Text(log.name ?? "Unknown Log")
                        }
                        .accessibility(identifier: log.name ?? "unknownLog")
                    }
                }
                .navigationBarTitle("Select Log", displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    showingSheet = false
                })

                if showingNotification {
                    notificationView
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
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
    }
}
