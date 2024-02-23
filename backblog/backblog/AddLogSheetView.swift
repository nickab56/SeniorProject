import SwiftUI
import CoreData

struct AddLogSheetView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newLogName = ""
    @State private var showingAllFriends = false
    @State private var searchText = ""
    
    @ObservedObject var logsViewModel: LogsViewModel

    let collaborators = ["Alice", "Bob", "Charlie"]
    let friends = ["Dave", "Eva", "Frank", "George", "Hannah", "Ian", "Jill", "Kevin", "Luna", "Mike", "Nora", "Oscar", "Patty", "Quinn", "Rachel", "Steve", "Tina", "Uma", "Vince", "Wendy", "Xander", "Yvonne", "Zack"]

    // Filtered or limited list of friends based on search text and showingAllFriends flag
    var filteredFriends: [String] {
        let filtered = friends.filter { friend in
            searchText.isEmpty || friend.lowercased().contains(searchText.lowercased())
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

                Section(header: Text("Current Collaborators")) {
                    ForEach(collaborators, id: \.self) { collaborator in
                        HStack {
                            Image(systemName: "person.crop.circle")
                            Text(collaborator)
                        }
                    }
                }

                Section(header: Text("Add Collaborators")) {
                    TextField("Search Friends", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)

                    List {
                        ForEach(filteredFriends, id: \.self) { friend in
                            HStack {
                                Image(systemName: "person.crop.circle")
                                Text(friend)
                                Spacer()
                                Button(action: {
                                    // Placeholder action for future functionality
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
                    .transition(.opacity)
                }

                Button(action: {
                    addNewLog()
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
    }

    private func addNewLog() {
        let newLog = LocalLogData(context: viewContext)
        newLog.name = newLogName
        newLog.log_id = Int64(UUID().hashValue)

        do {
            try viewContext.save()
            logsViewModel.fetchLogs() // FIX THIS
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
