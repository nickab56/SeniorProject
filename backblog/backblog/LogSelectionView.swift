import SwiftUI

struct LogSelectionView: View {
    @StateObject var vm: LogSelectionViewModel
    @Binding var showingSheet: Bool

    init(selectedMovieId: Int, showingSheet: Binding<Bool>) {
        _showingSheet = showingSheet
        _vm = StateObject(wrappedValue: LogSelectionViewModel(selectedMovieId: selectedMovieId))
    }
    
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
                                showingSheet = false // Consider how to handle new log creation
                            }
                            else {
                                vm.addMovieToSelectedLogs()
                                showingSheet = false
                            }
                        }) {
                            Text(vm.selectedLogs.isEmpty ? "New Log" : "Add")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .disabled(!vm.logsWithDuplicates.isEmpty) // Disable "Done" if there are duplicates

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
