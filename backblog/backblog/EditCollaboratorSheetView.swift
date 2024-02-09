import SwiftUI
import CoreData

struct EditCollaboratorSheetView: View {
    @Binding var isPresented: Bool
    
    @State private var showingAllFriends = false // To toggle the full list of friends
    @State private var searchText = "" // For the search bar
    
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
        // TODO: need to add proper functionality to this action sheet
        NavigationView {
            Form {
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
                        
                        if !showingAllFriends && friends.count > 5 {
                            Button("View More") {
                                withAnimation {
                                    showingAllFriends = true
                                }
                            }
                        }
                    }
                    .transition(.opacity) // Apply a fade-in transition
                }
                
                Section{
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                    }
                    
                }
            }
            .navigationBarTitle("Edit Collaborators", displayMode: .inline)
        }
        .preferredColorScheme(.dark)
    }
}
