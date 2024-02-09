//
//  SocialView.swift
//  backblog
//
//  Created by Nick Abegg on 12/23/23.
//  Updated by Jake Buhite on 02/09/24.

import SwiftUI
import FirebaseAuth
import CoreData

struct SocialView: View {
    @State private var logs: [LogData] = []
    @State private var selectedTab = "Logs"
    @State private var userData: UserData?
    @State private var friends: [UserData] = []
    @State private var friendRequests: [(FriendRequestData, UserData)] = []
    @State private var logRequests: [(LogRequestData, UserData)] = []
    
    @State private var showingNotification = false
    @State private var notificationMessage = ""
    
    @State private var showingSendFriendReqSheet = false
    
    var body: some View {
        fetchUserData()
        fetchLogs()
        fetchFriends()
        fetchFriendRequests()
        fetchLogRequests()
        
        return VStack {
            HStack {
                Spacer()
                
                NavigationLink(destination: SettingsView(userData: $userData)) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            HStack {
                // Display user's avatar
                let avatarPreset = userData?.avatarPreset ?? 1
                let preset = getAvatarId(avatarPreset: avatarPreset)
                
                Image(uiImage: UIImage(named: preset) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                
                Text(userData?.username ?? "")
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

            
            if selectedTab == "Logs" {
                ScrollView {
                    if (logs.count > 0) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(logs) { log in
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
                    
                    Button(action: {
                        showingSendFriendReqSheet = true
                    }) {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
                }.padding()
                
                ScrollView {
                    LazyVStack {
                        if friendRequests.isEmpty == false {
                            HStack {
                                Text("Friend Request")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                            }
                            
                            ForEach(friendRequests, id: \.0) { friendReq in 
                                RequestList(notificationActive: $showingNotification, notificationMessage: $notificationMessage, reqId: friendReq.0.requestId ?? "", reqUserId: friendReq.1.userId ?? "", reqType: "friend", reqUsername: friendReq.1.username ?? "", avatarPreset: friendReq.1.avatarPreset ?? 1)
                                    .padding(.horizontal)
                            }
                        }
                        if logRequests.isEmpty == false {
                            HStack {
                                Text("Log Request")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                            }
                            
                            ForEach(logRequests, id: \.0) { logReq in 
                                RequestList(notificationActive: $showingNotification, notificationMessage: $notificationMessage, reqId: logReq.0.requestId ?? "", reqUserId: logReq.1.userId ?? "", reqType: "log", reqUsername: logReq.1.username ?? "", avatarPreset: logReq.1.avatarPreset ?? 1 )
                                    .padding(.horizontal)
                            }
                        }
                        if friends.isEmpty == false {
                            HStack {
                                Text("Friends")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray)
                            }
                            ForEach(friends) { friendId in FriendListElement(friendId: friendId.userId ?? "", userId: FirebaseService.shared.auth.currentUser?.uid ?? "", username: friendId.username ?? "", avatarPreset: friendId.avatarPreset ?? 1)
                                    .padding(.horizontal)
                            }
                        } else {
                            Text("No friends found.")
                                .foregroundColor(.gray)
                        }
                        
                        if showingNotification {
                            notificationView
                        }
                        
                    }
                    .padding(.trailing)
                    .padding(.bottom, 175)
                }
            }
        }.padding(.top, 80)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showingSendFriendReqSheet) {
            AddFriendSheetView(isPresented: $showingSendFriendReqSheet, notificationMsg: $notificationMessage, notificationActive: $showingNotification)
        }
    }
    
    private var notificationView: some View {
        Text(notificationMessage)
            .padding()
            .foregroundColor(.white)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .padding(.bottom, 50)
            .transition(.move(edge: .bottom))
            .accessibility(identifier: "NotificationView")
    }
    
    private func fetchUserData() {
        DispatchQueue.main.async {
            Task {
                guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                    return
                }
                do {
                    let result = try await UserRepository.getUser(userId:userId).get()
                    userData = result
                } catch {
                    print("Error fetching user: \(error.localizedDescription)")
                }
            }
        }
    }
    private func fetchLogs() {
        DispatchQueue.main.async {
            Task {
                guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                    return
                }
                do {
                    let result = try await LogRepository.getLogs(userId: userId, showPrivate: false).get()
                    logs = result
                } catch {
                    print("Error fetching logs: \(error.localizedDescription)")
                }
            }
        }
    }
    private func fetchFriends() {
        DispatchQueue.main.async {
            Task {
                guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                    return
                }
                do {
                    let result = try await FriendRepository.getFriends(userId: userId).get()
                    friends = result.sorted { ($0.userId ?? "") > ($1.userId ?? "") }
                } catch {
                    print("Error fetching friends: \(error.localizedDescription)")
                }
            }
        }
    }
    private func fetchLogRequests() {
        DispatchQueue.main.async {
            Task {
                guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                    return
                }
                do {
                    let logReq = try await UserRepository.getLogRequests(userId: userId).get() // Returns [LogRequestData]
                    
                    let result: [(LogRequestData, UserData)] = try await withThrowingTaskGroup(of: (LogRequestData, UserData).self) { group in
                        for req in logReq {
                            group.addTask {
                                do {
                                    let user = try await UserRepository.getUser(userId: req.senderId ?? "").get()
                                    return (req, user)
                                } catch {
                                    throw error
                                }
                            }
                        }
                        
                        var resultArr: [(LogRequestData, UserData)] = []
                        
                        for try await result in group {
                            resultArr.append(result)
                        }
                        
                        return resultArr
                    }
                    logRequests = result
                } catch {
                    print("Error fetching log requests: \(error.localizedDescription)")
                }
            }
        }
    }
    private func fetchFriendRequests() {
        DispatchQueue.main.async {
            Task {
                guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                    return
                }
                do {
                    let friendReq = try await UserRepository.getFriendRequests(userId: userId).get() // Returns [FriendRequestData]
                    
                    let result: [(FriendRequestData, UserData)] = try await withThrowingTaskGroup(of: (FriendRequestData, UserData).self) { group in
                        for req in friendReq {
                            group.addTask {
                                do {
                                    let user = try await UserRepository.getUser(userId: req.senderId ?? "").get()
                                    return (req, user)
                                } catch {
                                    throw error
                                }
                            }
                        }
                        
                        var resultArr: [(FriendRequestData, UserData)] = []
                        
                        for try await result in group {
                            resultArr.append(result)
                        }
                        
                        return resultArr
                    }
                    
                    friendRequests = result
                } catch {
                    print("Error fetching log requests: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct RequestList: View {
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
                    updateRequest(reqId: reqId, reqType: reqType, accepted: true)
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
                    updateRequest(reqId: reqId, reqType: reqType, accepted: false)
                }) {
                    Image(systemName: "xmark.circle")
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                }.accessibility(identifier: "Remove Request")
                
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func updateRequest(reqId: String, reqType: String, accepted: Bool) {
        DispatchQueue.main.async {
            Task {
                do {
                    if reqType.lowercased() == "log" {
                        _ = try await FriendRepository.updateLogRequest(logRequestId: reqId, isAccepted: accepted).get()
                    } else {
                        _ = try await FriendRepository.updateFriendRequest(friendRequestId: reqId, isAccepted: accepted).get()
                    }
                    
                    // Successful
                    withAnimation {
                        notificationMessage = "Successfully updated request!"
                        notificationActive = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            notificationActive = false
                        }
                    }
                } catch {
                    print("Error updating request: \(error.localizedDescription)")
                    
                    withAnimation {
                        notificationMessage = "Error updating request"
                        notificationActive = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            notificationActive = false
                        }
                    }
                }
            }
        }
    }
}
