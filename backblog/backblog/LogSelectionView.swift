//
//  LogSelectionView.swift
//  backblog
//
//  Created by Nick Abegg on 1/--/24.
//
import SwiftUI

struct LogSelectionView: View {
    @StateObject var vm: LogSelectionViewModel // ViewModel handling log selection logic.
    @Binding var showingSheet: Bool // Binding to control the visibility of the sheet.

    @State private var showingCreateLogPopup = false
    
    /**
     Initializes the view with the selected movie ID and binding for the sheet visibility.
     
     - Parameters:
         - selectedMovieId: The ID of the selected movie.
         - showingSheet: Binding to control the sheet's visibility.
     */
    init(selectedMovieId: Int, showingSheet: Binding<Bool>) {
        _showingSheet = showingSheet
        _vm = StateObject(wrappedValue: LogSelectionViewModel(selectedMovieId: selectedMovieId, fb: FirebaseService(), movieService: MovieService()))
    }
    
    /**
     A view for selecting logs to which a movie will be added.
     */
    var body: some View {
        ZStack {
            NavigationView {
                Form {
                    Section {
                        ForEach(vm.logs) { logType in
                            MultipleSelectionRow(title: vm.getTitle(logType: logType), isSelected: vm.isLogSelected(logType: logType)) {
                                let logId = vm.getLogId(logType: logType)
                                vm.handleLogSelection(logId: logId)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    Section {
                        Button(action: {
                            if vm.selectedLogs.isEmpty {
                                showingCreateLogPopup = true
                            } else {
                                vm.addMovieToSelectedLogs()
                                showingSheet = false
                            }
                            HapticFeedbackManager.shared.triggerImpactFeedback()
                        }) {
                            Text(vm.selectedLogs.isEmpty ? "New Log" : "Add")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .disabled(!vm.logsWithDuplicates.isEmpty)

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

            if vm.showingNotification {
                NotificationView()
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                vm.showingNotification = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: vm.showingNotification)
        .preferredColorScheme(.dark)
        .overlay {
            if showingCreateLogPopup {
                CreateLogPopup(isVisible: $showingCreateLogPopup) { logName in
                    vm.createNewLogWithName(logName)
                }
                .transition(.scale)
            }
        }
    }
    
    /**
     A view component representing a notification, used to indicate when a movie is already in a log.
     */
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

struct CreateLogPopup: View {
    @Binding var isVisible: Bool
    var onCommit: (String) -> Void
    @State private var logName: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Create New Log")
                .font(.headline)
                .padding(.top, 20)
            
            TextField("Log Name", text: $logName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Divider()
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    isVisible = false
                }
                .foregroundColor(Color(UIColor.systemRed))
                .font(.body)
                
                Spacer()
                
                Button("Create Log") {
                    onCommit(logName)
                    isVisible = false
                    HapticFeedbackManager.shared.triggerNotificationFeedback(type: .success)
                }
                .disabled(logName.isEmpty)
                .foregroundColor(logName.isEmpty ? .gray : Color(UIColor.systemBlue))
                .font(.body)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
        .shadow(radius: 10)
        .frame(width: 300)
        .transition(.scale)
    }
}



/**
 A row view for multiple selection scenarios, used for selecting logs.
 
 - Parameters:
     - title: The title of the row.
     - isSelected: Boolean indicating if the row is selected.
     - action: The action to perform when the row is tapped.
 */
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
