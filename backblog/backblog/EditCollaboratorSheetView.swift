//
//  EditCollaboratorSheetView.swift
//  backblog
//
//  Created by Nick Abegg on 2/18/24.
//  Updated by Jake Buhite on 2/23/24
//
//  Description: View for editing collaborators for a log, allowing users to add or remove collaborators.
//

import SwiftUI
import CoreData

/**
 Displays a single log item with its related details.
 
 - Parameters:
     - isPresented: A binding to control the presentation of the sheet.
 */
struct EditCollaboratorSheetView: View {
    @Binding var isPresented: Bool
    
    @State private var showingAllFriends = false // To toggle the full list of friends
    @State private var searchText = "" // For the search bar
    
    @State public var collaborators = ["Alice", "Bob", "Charlie"]
    public var allFriends = ["Dave", "Eva", "Frank", "George", "Hannah", "Ian", "Jill", "Kevin", "Luna", "Mike", "Nora", "Oscar", "Patty", "Quinn", "Rachel", "Steve", "Tina", "Uma", "Vince", "Wendy", "Xander", "Yvonne", "Zack"]
    
    // Computed property to get the list of friends not already collaborators
    var friends: [String] {
        allFriends.filter { !collaborators.contains($0) }
    }
    
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
    
    /**
     The body of `EditCollaboratorSheetView` view, responsible for displaying the layout and SwiftUI elements.
     */
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Collaborators")) {
                    ForEach(collaborators, id: \.self) { collaborator in
                        HStack {
                            Image(systemName: "person.crop.circle")
                            Text(collaborator)
                        }
                    }
                    .onDelete(perform: removeCollaborator)
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
                                    addCollaborator(friend: friend)
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
                    .transition(.opacity)
                }
                
                Section {
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
    
    /**
     Adds a friend as a collaborator.
     
     - Parameters:
         - friend: The friend to add as a collaborator.
     */
    func addCollaborator(friend: String) {
        withAnimation {
            collaborators.append(friend)
        }
    }
    
    /**
     Removes a collaborator at the specified index set.
     
     - Parameters:
         - offsets: The index set of the collaborator(s) to remove.
     */
    func removeCollaborator(at offsets: IndexSet) {
        withAnimation {
            collaborators.remove(atOffsets: offsets)
        }
    }
}
