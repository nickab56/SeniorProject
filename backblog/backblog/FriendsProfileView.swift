//
//  FriendsProfileView.swift
//  backblog
//
//  Created by Jake Buhite on 02/08/24.
//

import SwiftUI
import FirebaseAuth
import CoreData

struct FriendsProfileView: View {
    @StateObject var viewModel: FriendsProfileViewModel
    @State private var selectedTab = "Logs"
    
    @State private var showActionSheet = false
    @State private var showBlockConfirmation = false
    
    init(friendId: String) {
        _viewModel = StateObject(wrappedValue: FriendsProfileViewModel(friendId: friendId, fb: FirebaseService()))
    }
    
    var body: some View {
        return VStack {
            HStack {
                Spacer()
                
                // Conditional Add/Remove Friend Button
                if viewModel.userIsFriend() {
                    Button(action: {
                        viewModel.removeFriend()
                    }) {
                        Image(systemName: "person.fiil.badge.minus")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 15)
                } else {
                    Button(action: {
                        viewModel.sendFriendRequest()
                    }) {
                        Image(systemName: "person.fill.badge.plus")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 15)
                }
                Button(action: {
                                    self.showBlockConfirmation = true
                                }) {
                                    Image(systemName: "person.fill.xmark")
                                        .imageScale(.large)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 15)
                                .padding(.top, 15)
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
                                FriendListElement(
                                    friendId: friendId.userId ?? "", userId: viewModel.getUserId(), username: friendId.username ?? "", avatarPreset: friendId.avatarPreset ?? 1)
                                    .padding(.horizontal)
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
        .alert(isPresented: $showBlockConfirmation) { // Block User Confirmation Alert
            Alert(
                title: Text("Block User"),
                message: Text("Are you sure you want to remove and block this friend?"),
                primaryButton: .destructive(Text("Block")) {
                    viewModel.blockUser()
                },
                secondaryButton: .cancel()
            )
        }
        .padding(.top, 80)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
    
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
