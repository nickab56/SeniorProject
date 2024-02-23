//
//  EditLogSheetView.swift
//  backblog
//
//  Created by Nick Abegg on 2/18/24.
//

import SwiftUI
import CoreData

struct EditLogSheetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @ObservedObject var vm: LogViewModel
    
    var onLogDeleted: (() -> Void)?
    
    @State private var draftLogName: String
    @State private var draftMovies: [(MovieData, String)]
    @State private var showDeleteConfirmation: Bool = false

    init(isPresented: Binding<Bool>, vm: LogViewModel, onLogDeleted: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.vm = vm
        self.onLogDeleted = onLogDeleted

        switch vm.log {
        case .localLog(let localLogData):
            _draftLogName = State(initialValue: localLogData.name ?? "")
        default:
            _draftLogName = State(initialValue: "")
        }

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
                    .onDelete(perform: { indexSet in
                        draftMovies = vm.deleteDraftMovie(movies: draftMovies, at: indexSet)
                    })
                    //.onDelete(perform: deleteDraftMovie)
                    .onMove(perform: { indices, newOffset in
                        draftMovies = vm.moveDraftMovies(movies: draftMovies, from: indices, to: newOffset)
                    })
                }

                Section {
                    Button("Save") {
                        vm.saveChanges(draftLogName: draftLogName, movies: draftMovies)
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
                    onLogDeleted?()
                    isPresented = false
                }
                Button("No", role: .cancel) {}
            }
        }
        .preferredColorScheme(.dark)
    }
}
