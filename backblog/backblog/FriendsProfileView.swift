//
//  FriendsProfileView.swift
//  backblog
//
//  Created by Jake Buhite on 02/08/24.
//

import SwiftUI
import FirebaseAuth
import CoreData

/**
 Displays the profile view for a friend, including their logs and list of friends.

 Users can view a friend's public logs, their friends list, and have options to add or remove the friend, or block the user. The view uses the `FriendsProfileViewModel` to fetch and manage the friend's data, including logs and friend relationships. The view dynamically adjusts to show either a button to add the friend or options to remove or block them based on the current relationship status.

 - Properties:
    - `viewModel`: The view model managing the friend's profile data.
    - `selectedTab`: Controls which tab is currently selected ("Logs" or "Friends").
    - `showActionSheet`: Determines if the action sheet for adding/removing/blocking the friend is visible.
    - `showBlockConfirmation`: Controls the visibility of the confirmation dialog for blocking the user.
    - `showRemoveFriendConfirmation`: Controls the visibility of the confirmation dialog for removing the friend.

 The interface provides interactive elements such as buttons for friend management actions and navigation links to log details. Confirmation dialogs ensure that actions like removing a friend or blocking a user are intentional. A notification view is also included to display feedback messages resulting from user actions.
 */
struct FriendsProfileView: View {
    @StateObject var viewModel: FriendsProfileViewModel
    @State private var selectedTab = "Logs"
    
    @State private var showActionSheet = false
    @State private var showBlockConfirmation = false
    @State private var showRemoveFriendConfirmation = false
    
    @State private var activeAlert: ActiveAlert?

    @Environment(\.presentationMode) var presentationMode

    
    enum ActiveAlert: Identifiable {
        case blockUser, removeFriend
        
        // Conform to the Identifiable protocol
        var id: Self {
            return self
        }
    }
    
    init(friendId: String, user: UserData?) {
        _viewModel = StateObject(wrappedValue: FriendsProfileViewModel(friendId: friendId, fb: FirebaseService(), user: user))
    }
    
    var body: some View {
        return VStack {
                HStack {
                    Spacer()
                                if viewModel.userIsFriend() {
                                    // Remove Friend Button
                                    Button(action: {
                                        self.activeAlert = .removeFriend
                                    }) {
                                        Image(systemName: "person.fill.badge.minus")
                                            .imageScale(.large)
                                            .foregroundColor(.white)
                                    }
                                    .accessibilityIdentifier("RemoveFriendButton")
                                    .padding(.horizontal, 10)
                                    .padding(.top, 15)
                                } else {
                                    // Add Friend Button
                                    Button(action: {
                                        viewModel.sendFriendRequest()
                                    }) {
                                        Image(systemName: "person.fill.badge.plus")
                                            .imageScale(.large)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.top, 15)
                                    .accessibilityIdentifier("AddUserButton")
                                }
                                
                            // For the block user button
                            Button(action: {
                                self.activeAlert = .blockUser
                            }) {
                                Image(systemName: "person.fill.xmark")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                            .accessibilityIdentifier("BlockUserButton")
                            }
            HStack {
                // Display user's avatar
                let avatarPreset = viewModel.userData?.avatarPreset ?? 1
                let preset = getAvatarId(avatarPreset: avatarPreset)
                
                Image(uiImage: UIImage(named: preset) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                
                Text(viewModel.userData?.username ?? "")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                
                Spacer()
            }.padding(.leading)
                .padding(.top, -20)
            
            Picker("Options", selection: $selectedTab) {
                Text("Logs").tag("Logs")
                Text("Friends").tag("Friends")
            }
            .pickerStyle(SegmentedPickerStyle())
            .accessibility(identifier: "logsFriendsTabPicker")
            
            if viewModel.showingNotification {
                notificationView
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                viewModel.showingNotification = false
                            }
                        }
                    }
            }
            
            if selectedTab == "Logs" {
                ScrollView {
                    if (viewModel.logs.count > 0) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(viewModel.logs) { log in
                                NavigationLink(destination: LogDetailsView(log: LogType.log(log))) {
                                    LogItemView(log: LogType.log(log))
                                        .cornerRadius(15)
                                        .accessibility(identifier: "logItem_\(log.logId ?? "")")
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No public logs found.")
                            .foregroundColor(.gray)
                    }
                }
            } else if selectedTab == "Friends" {
                HStack {
                    Text("Friends")
                        .font(.system(size: 30))
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                }.padding()
                
                ScrollView {
                    LazyVStack {
                        if viewModel.friends.isEmpty == false {
                            HStack {
                                Text("Friends")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                            }
                            ForEach(viewModel.friends) { friendId in 
                                if (viewModel.user?.blocked?[friendId.userId ?? ""] == nil) {
                                    FriendListElement(
                                        friendId: friendId.userId ?? "", userId: viewModel.getUserId(), username: friendId.username ?? "", avatarPreset: friendId.avatarPreset ?? 1, user: viewModel.userData)
                                        .padding(.horizontal)
                                }
                            }
                        } else {
                            Text("No friends found.")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.trailing)
                    .padding(.bottom, 175)
                }
            }
        }
        .confirmationDialog("Select an Action", isPresented: $showActionSheet) {
            if (viewModel.userIsFriend()) {
                Button("Remove Friend", role: .destructive, action: viewModel.removeFriend)
            } else {
                Button("Add Friend", role: nil, action: viewModel.sendFriendRequest)
            }
            Button("Block User", role: .destructive, action: { self.showBlockConfirmation = true })
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .blockUser:
                return Alert(
                    title: Text("Block User"),
                    message: Text("Are you sure you want to block this user? This action cannot be undone."),
                    primaryButton: .destructive(Text("Block")) {
                        viewModel.blockUser {
                            presentationMode.wrappedValue.dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .removeFriend:
                return Alert(
                    title: Text("Remove Friend"),
                    message: Text("Are you sure you want to remove this friend?"),
                    primaryButton: .destructive(Text("Remove")) {
                        viewModel.removeFriend()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .padding(.top, 80)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
    
    /**
     Constructs a notification view displaying the current message from the view model.

     - Returns: A styled notification message view.
    */
    private var notificationView: some View {
        Text(viewModel.notificationMessage)
            .padding()
            .background(Color.gray.opacity(0.9))
            .foregroundColor(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .zIndex(1) // Ensure the notification view is always on top
            .accessibility(identifier: "NotificationsView")
            .animation(.easeInOut(duration: 2), value: viewModel.notificationMessage)
    }
}
