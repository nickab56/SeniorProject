//
//  SocialView.swift
//  backblog
//
//  Created by Nick Abegg on 12/23/23.
//  Updated by Jake Buhite on 02/09/24.
//  Description: View responsible for displaying the social page. Both a users public logs and their friends, friends request, and log request
//

import SwiftUI
import FirebaseAuth
import CoreData

/**
 A view component that displays the social features of the application including user's logs, friends, and friend requests.
 */
struct SocialView: View {
    @StateObject var vm: SocialViewModel
    
    /**
     Initializes the `SocialView` with a new instance of `SocialViewModel`.
     */
    init() {
        _vm = StateObject(wrappedValue: SocialViewModel(fb: FirebaseService()))
    }
    
    /**
     The body of the `SocialView`, defining the SwiftUI content and layout for the social page.
     */
    var body: some View {
        return VStack {
            HStack {
                Spacer()
                
                // Settings navigation link
                NavigationLink(destination: SettingsView(vm: vm)) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            
            // User profile display
            HStack {
                let avatarPreset = vm.userData?.avatarPreset ?? 1
                let preset = getAvatarId(avatarPreset: avatarPreset)
                
                Image(uiImage: UIImage(named: preset) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .accessibility(identifier: "UserProfileImage")
                
                Text(vm.userData?.username ?? "")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                
                Spacer()
            }.padding(.leading)
                .padding(.top, -20)
            
            // Tab picker for Logs and Friends
            Picker("Options", selection: $vm.selectedTab) {
                Text("Logs").tag("Logs")
                Text("Friends").tag("Friends")
            }
            .pickerStyle(SegmentedPickerStyle())
            .accessibility(identifier: "logsFriendsTabPicker")

            
            // Logs Tab View
            if vm.selectedTab == "Logs" {
                ScrollView {
                    if (vm.logs.count > 0) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(vm.logs) { log in
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
                            .accessibilityIdentifier("NoLogsText")
                    }
                }
            } else if vm.selectedTab == "Friends" {
                // Friends Tab View
                HStack {
                    
                    Text("Friends")
                        .font(.system(size: 30))
                        .bold()
                        .foregroundColor(.white)
                        .accessibility(identifier: "FriendsSection")
                    
                    Spacer()
                    
                    Button(action: {
                        vm.showingSendFriendReqSheet = true
                    }) {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.white)
                    }
                    .accessibilityIdentifier("addFriendButton")
                    .frame(width: 80, height: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
                }.padding()
                
                ScrollView {
                    LazyVStack {
                        if vm.friendRequests.isEmpty == false {
                            HStack {
                                Text("Friend Request")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                            }
                            
                            ForEach(vm.friendRequests, id: \.0) { friendReq in
                                RequestList(viewModel: vm, notificationActive: $vm.showingNotification, notificationMessage: $vm.notificationMessage, reqId: friendReq.0.requestId ?? "", reqUserId: friendReq.1.userId ?? "", reqType: "friend", reqUsername: friendReq.1.username ?? "", avatarPreset: friendReq.1.avatarPreset ?? 1)
                                    .padding(.horizontal)
                            }
                        }
                        if vm.logRequests.isEmpty == false {
                            HStack {
                                Text("Log Request")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                            }
                            
                            ForEach(vm.logRequests, id: \.0) { logReq in
                                RequestList(viewModel: vm, notificationActive: $vm.showingNotification, notificationMessage: $vm.notificationMessage, reqId: logReq.0.requestId ?? "", reqUserId: logReq.1.userId ?? "", reqType: "log", reqUsername: logReq.1.username ?? "", avatarPreset: logReq.1.avatarPreset ?? 1 )
                                    .padding(.horizontal)
                            }
                        }
                        if vm.friends.isEmpty == false {
                            HStack {
                                Text("Friends")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                    .accessibility(identifier: "FriendsSectionHeader")
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                            }
                            ForEach(vm.friends) { friendId in FriendListElement(friendId: friendId.userId ?? "", userId: vm.getUserId(), username: friendId.username ?? "", avatarPreset: friendId.avatarPreset ?? 1)
                                    .padding(.horizontal)
                            }
                        } else {
                            Text("No friends found.")
                                .foregroundColor(.gray)
                                .accessibility(identifier: "NoFriendsText")
                        }
                        
                        if vm.showingNotification {
                            notificationView
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
                    .padding(.trailing)
                    .padding(.bottom, 175)
                }
            }
        }.padding(.top, 80)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $vm.showingSendFriendReqSheet) {
            AddFriendSheetView(viewModel: vm, isPresented: $vm.showingSendFriendReqSheet, notificationMsg: $vm.notificationMessage, notificationActive: $vm.showingNotification)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: {
            vm.fetchLogs()
        })
    }
    
    /**
     Displays a notification view with a custom message.

     This function creates a SwiftUI view that shows a notification message to the user.

     - Returns: A view component displaying the notification message.
    */
    private var notificationView: some View {
        Text(vm.notificationMessage)
            .padding()
            .background(Color.gray.opacity(0.9))
            .foregroundColor(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .zIndex(1) // Ensure the notification view is always on top
            .accessibility(identifier: "NotificationsView")
    }
}


/**
 A view for displaying individual requests in a list, such as friend or log requests.

 This view shows the requester's username and avatar, and provides buttons to accept or reject the request. It uses the `SocialViewModel` for handling request updates and navigates to the requester's profile on tap.

 - Parameters:
    - viewModel: The view model providing request data and update functions.
    - notificationActive: Binding to control the display of notifications.
    - notificationMessage: Binding to the message displayed in notifications.
    - reqId, reqUserId, reqType, reqUsername, avatarPreset: Properties identifying the request and requester.

 - Returns: A view component for a request item with accept and reject options.
*/

struct RequestList: View {
    @ObservedObject var viewModel: SocialViewModel
    @Binding var notificationActive: Bool
    @Binding var notificationMessage: String
    
    let reqId: String
    let reqUserId: String
    let reqType: String
    let reqUsername: String
    let avatarPreset: Int
    
    var body: some View {
        NavigationLink(destination: FriendsProfileView(friendId: reqUserId)) {
            HStack {
                let preset = getAvatarId(avatarPreset: avatarPreset)
                Image(uiImage: UIImage(named: preset) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text(reqUsername)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    viewModel.updateRequest(reqId: reqId, reqType: reqType, accepted: true)
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.blue)
                            .frame(width: 25, height: 25)
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.black)
                    }.accessibility(identifier: "Accept Request")
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    viewModel.updateRequest(reqId: reqId, reqType: reqType, accepted: false)
                }) {
                    Image(systemName: "xmark.circle")
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                }.accessibility(identifier: "Remove Request")
                
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
