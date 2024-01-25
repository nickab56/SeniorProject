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

    var body: some View {
        NavigationView {
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
        }
    }

    private func addMovieToLog(movieId: Int, log: LogEntity) {
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

