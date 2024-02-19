//
//  EditLogSheetView.swift
//  backblog
//
//  Created by Nick Abegg on 2/18/24.
//

import SwiftUI
import CoreData

struct EditLogSheetView: View {
    @Binding var isPresented: Bool
    @ObservedObject var vm: LogViewModel
    
    @State private var draftLogName: String
    @State private var draftMovies: [(MovieData, String)]
    @State private var showDeleteConfirmation: Bool = false

    init(isPresented: Binding<Bool>, vm: LogViewModel) {
        self._isPresented = isPresented
        self.vm = vm

        // Initialize draftLogName based on the LogType
        switch vm.log {
        case .localLog(let localLogData):
            _draftLogName = State(initialValue: localLogData.name ?? "")
        default:
            _draftLogName = State(initialValue: "")
        }

        // Initialize draftMovies with the movies from the view model
        _draftMovies = State(initialValue: vm.movies)
    }



    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Log Name")) {
                    TextField("Log Name", text: $draftLogName)
                }

                Section(header: Text("Unwatched Movies")) {
                    ForEach(draftMovies, id: \.0.id) { (movie, _) in
                        Text(movie.title ?? "Unknown Movie")
                    }
                    .onDelete(perform: deleteDraftMovie)
                    .onMove(perform: moveDraftMovies)
                }

                Section {
                    Button("Save") {
                        saveChanges()
                        isPresented = false
                    }

                    Button("Delete Log") {
                        showDeleteConfirmation = true
                    }
                    .foregroundColor(.red)

                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .navigationBarTitle("Edit Log", displayMode: .inline)
            .toolbar {
                EditButton()
            }
            .alert("Are you sure you want to delete this log?", isPresented: $showDeleteConfirmation) {
                Button("Yes", role: .destructive) {
                    vm.deleteLog()
                    isPresented = false
                }
                Button("No", role: .cancel) {}
            }
        }
    }

    private func deleteDraftMovie(at offsets: IndexSet) {
        draftMovies.remove(atOffsets: offsets)
    }

    private func moveDraftMovies(from source: IndexSet, to destination: Int) {
        draftMovies.move(fromOffsets: source, toOffset: destination)
    }

    private func saveChanges() {
        // Apply changes from draft state to the view model
        vm.updateLogName(newName: draftLogName)
        vm.movies = draftMovies
        // Implement other necessary updates in the view model
    }
}
