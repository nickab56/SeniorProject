//
//  EditLogSheetView.swift
//  backblog
//
//  Created by Nick Abegg on 2/18/24.
//  Updated by Jake Buhite on 2/23/23.
//
//  Description: View for editing the details of a log.
//

import SwiftUI
import CoreData

/**
 View for editing the details of a log, including its name and movies.
 
 - Parameters:
     - isPresented: Binding to control the presentation of the view.
     - vm: The view model for the log being edited.
     - onLogDeleted: Closure to be called when the log is deleted.
 */
struct EditLogSheetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @ObservedObject var vm: LogViewModel
    
    var onLogDeleted: (() -> Void)?
    
    
    @State private var draftLogName: String
    @State private var draftPublicLog: Bool = true
    @State private var draftMovies: [(MovieData, String)]
    @State private var showDeleteConfirmation: Bool = false

    /**
     Initializes the `EditLogSheetView` with the given bindings and view model.
     
     - Parameters:
         - isPresented: Binding to control the presentation of the view.
         - vm: The view model for the log being edited.
         - onLogDeleted: Closure to be called when the log is deleted.
     */
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
        
        switch vm.log {
        case .log(let logData):
            _draftPublicLog = State(initialValue: logData.isVisible ?? true)
        case .localLog:
            _draftPublicLog = State(initialValue: false)
        }
        
    }

    /**
     The body of the `EditLogSheetView`, defining the layout and SwiftUI elements.
     */
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Log Name")) {
                    TextField("Log Name", text: $draftLogName)
                }
                
                if case .log(_) = vm.log {
                    Section {
                        Toggle(isOn: $draftPublicLog) {
                            Text("Public Log")
                        }
                    }
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
                        vm.updateLogVisibility(isVisible: draftPublicLog)
                        vm.saveChanges(draftLogName: draftLogName, movies: draftMovies)
                        isPresented = false
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)


                    Button("Delete Log") {
                        showDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)


                    Button("Cancel") {
                        isPresented = false
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                }
            }
            .navigationBarTitle("Edit Log", displayMode: .inline)
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
