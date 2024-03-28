//
//  AddLogSheetView.swift
//  backblog
//
//  Created by Nick Abegg on 2/2/24.
//  Updated by Jake Buhite on 2/23/24.
//
//  Description: View for adding a new log for both Firebase logs and CoreData logs.
//

import SwiftUI
import CoreData

/**
 View for adding a new log, including options to name the log and add collaborators.
 */
struct AddLogSheetView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newLogName = ""
    @State private var isPublic = false
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

    /**
     The body of the 'AddLogSheetView' view, defining the SwiftUI content
     */
    var body: some View {
        NavigationView {
            Form {
                TextField("Log Name", text: $newLogName)
                    .accessibility(identifier: "newLogNameTextField")
                
                Section{
                    Toggle(isOn: $isPublic) {
                        Text("Public Log")
                    }
                }
                
                if (logsViewModel.getUserId() != nil) {
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
                                Spacer()
                                Button(action: {
                                    removeCollaborator(collaborator: collaborator)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color.red)
                                        .imageScale(.large)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .onDelete(perform: removeCollaborator)
                    }
                    .accessibility(identifier: "currentCollaboratorsSection")

                    
                    Section(header: Text("Add Collaborators")) {
                        if friends.count == 0 {
                            Text("No friends found.")
                        } else {
                            TextField("Search Friends", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)
                                .accessibility(identifier: "searchFriendsTextField")

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
                                        .accessibility(identifier: "addCollaboratorButton")
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
                        logsViewModel.addLog(name: newLogName, isVisible: isPublic, collaborators: collaborators.compactMap { $0.userId })
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

    /**
     Adds a new local log to CoreData with the entered log name.
     
     - Note: This method is used when the user is not logged in.
     */
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
    
    /**
     Adds a friend as a collaborator to the new log.
     
     - Parameters:
         - friend: The `UserData` object representing the friend to add as a collaborator.
     */
    private func addCollaborator(friend: UserData) {
        withAnimation {
            collaborators.append(friend)
        }
    }
    
    /**
     Removes a collaborator from the list of collaborators.
     
     - Parameters:
         - offsets: The index set of the collaborator to remove.
     */
    private func removeCollaborator(collaborator: UserData) {
        withAnimation {
            if let index = collaborators.firstIndex(of: collaborator) {
                collaborators.remove(at: index)
            }
        }
    }

    // Keep the existing function to support swipe-to-delete if needed
    private func removeCollaborator(at offsets: IndexSet) {
        withAnimation {
            collaborators.remove(atOffsets: offsets)
        }
    }

}
