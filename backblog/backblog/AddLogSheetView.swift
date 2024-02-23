import SwiftUI
import CoreData

struct AddLogSheetView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newLogName = ""
    @State private var showingAllFriends = false
    @State private var searchText = ""
    
    @ObservedObject var logsViewModel: LogsViewModel

    @State public var collaborators: [UserData] = []
    
    var friends: [UserData] {
        logsViewModel.friends.filter { !collaborators.contains($0) }
    }

    // Filtered or limited list of friends based on search text and showingAllFriends flag
    var filteredFriends: [UserData] {
        let filtered = friends.filter { friend in
            searchText.isEmpty || (friend.username?.lowercased().contains(searchText.lowercased()) ?? false)
        }
        if showingAllFriends {
            return filtered
        } else {
            return Array(filtered.prefix(5))
        }
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Log Name", text: $newLogName)
                    .accessibility(identifier: "newLogNameTextField")
                
                if (logsViewModel.getUserId() != nil) {
                    Section(header: Text("Current Collaborators")) {
                        ForEach(collaborators, id: \.self) { collaborator in
                            HStack {
                                Image(uiImage: UIImage(named: getAvatarId(avatarPreset: collaborator.avatarPreset ?? 1)) ?? UIImage())
                                Text(collaborator.username ?? "Unknown")
                            }
                        }
                        .onDelete(perform: removeCollaborator)
                    }
                    
                    Section(header: Text("Add Collaborators")) {
                        if friends.count == 0 {
                            Text("No friends found.")
                        } else {
                            TextField("Search Friends", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)

                            List {
                                ForEach(filteredFriends, id: \.self) { friend in
                                    HStack {
                                        Image(uiImage: UIImage(named: getAvatarId(avatarPreset: friend.avatarPreset ?? 1)) ?? UIImage())
                                        Text(friend.username ?? "Unknown")
                                        Spacer()
                                        Button(action: {
                                            addCollaborator(friend: friend)
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(Color.blue)
                                                .imageScale(.large)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }

                                if !showingAllFriends && friends.count > 4 {
                                    Button("View More") {
                                        withAnimation {
                                            showingAllFriends = true
                                        }
                                    }
                                }
                            }
                            .transition(.opacity) // Apply a fade-in transition
                        }
                    }
                    .transition(.opacity)
                }

                Button(action: {
                    if (logsViewModel.getUserId() != nil) {
                        logsViewModel.addLog(name: newLogName, isVisible: true, collaborators: collaborators.compactMap { $0.userId })
                    } else {
                        addNewLocalLog()
                    }
                    isPresented = false
                }) {
                    Text("Add Log")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .accessibility(identifier: "createLogButton")
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                }
                .accessibility(identifier: "cancelAddLogButton")
            }
            .navigationBarTitle("New Log", displayMode: .inline)
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: {
            if (logsViewModel.getUserId() != nil) {
                logsViewModel.getFriends()
            }
        })
    }

    private func addNewLocalLog() {
        let newLog = LocalLogData(context: viewContext)
        newLog.name = newLogName
        newLog.log_id = Int64(UUID().hashValue)

        do {
            try viewContext.save()
            logsViewModel.fetchLogs() // TODO: FIX THIS
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func addCollaborator(friend: UserData) {
        withAnimation {
            collaborators.append(friend)
        }
    }
    
    private func removeCollaborator(at offsets: IndexSet) {
        withAnimation {
            collaborators.remove(atOffsets: offsets)
        }
    }
}
