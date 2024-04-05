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
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAllFriends = false // To toggle the full list of friends
    @State private var searchText = "" // For the search bar
    
    @ObservedObject var vm: LogViewModel
    
    @State public var collaborators: [UserData] = []
    
    init(isPresented: Binding<Bool>, vm: LogViewModel) {
        self._isPresented = isPresented
        self.vm = vm
        self._collaborators = State(initialValue: vm.collaborators)
    }
    
    // Computed property to get the list of friends not already collaborators
    var friends: [UserData] {
        vm.friends.filter { !collaborators.contains($0) && $0.userId != vm.log.toLog()!.owner?.userId }
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
    
    /**
     The body of `EditCollaboratorSheetView` view, responsible for displaying the layout and SwiftUI elements.
     */
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Collaborators")) {
                    ForEach(collaborators, id: \.self) { collaborator in
                        HStack {
                            Image(uiImage: UIImage(named: getAvatarId(avatarPreset: collaborator.avatarPreset ?? 1)) ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            Text(collaborator.username ?? "Unknown")
                        }
                    }
                    .onDelete(perform: removeCollaborator)
                }
                .accessibilityIdentifier("currentCollabSection")
                
                Section(header: Text("Add Collaborators")) {
                    if friends.count == 0 {
                        Text("No friends found.")
                            .accessibilityIdentifier("collabNoFriends")
                    } else {
                        TextField("Search Friends", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 5)
                            .accessibilityIdentifier("searchCollabFriendsTextField")

                        List {
                            ForEach(filteredFriends, id: \.self) { friend in
                                HStack {
                                    Image(uiImage: UIImage(named: getAvatarId(avatarPreset: friend.avatarPreset ?? 1)) ?? UIImage())
                                        .resizable() // Allows the image to be resized
                                        .aspectRatio(contentMode: .fill) // Maintain the aspect ratio while filling the frame
                                        .frame(width: 40, height: 40) // Set the desired frame size for the image
                                        .clipShape(Circle()) // Clip the image to a circle shape
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Optional: Add a border around the circle
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
                        .accessibilityIdentifier("friendsList")
                        .transition(.opacity) // Apply a fade-in transition
                    }
                }
                
                Section {
                    Button(action: {
                        isPresented = false
                        // Save changes
                        vm.updateCollaborators(collaborators: collaborators.compactMap { $0.userId })
                    }) {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("collabDoneButton")
                    }
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                            .accessibilityIdentifier("collabCancelButton")
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
    func addCollaborator(friend: UserData) {
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
