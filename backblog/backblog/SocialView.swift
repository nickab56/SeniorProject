//
//  SocialView.swift
//  backblog
//
//  Created by Nick Abegg on 12/23/23.
//  Updated by Josh Altmeyer on 01/18/24.
//
//  Description:
//  SocialView serves as the social interaction hub within the BackBlog app.
//  It features a user profile section, a tab view for Logs and Friends, and
//  a grid display of the user's logs.

import SwiftUI
import FirebaseAuth
import CoreData

struct SocialView: View {
    @State private var logs: [LogData] = []
    @State private var selectedTab = "Logs"
    @State private var userData: UserData?
    @State private var friends: [UserData] = []
    @State private var friendRequests: [FriendRequestData] = []
    @State private var logRequests: [LogRequestData] = []

    var body: some View {
        fetchUserData()
        fetchLogs()
        fetchFriends()
        var friendRequests: [String] {
                // TEMP need friends ID
                return ["nick", "jake", "TOM", "John"]
            }
        var logRequests: [String] {
                // TEMP need friends ID
                return ["Log1", "Log2", "Log3", "Log4"]
            }
        
        return VStack {
            HStack {
                Spacer()
                
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(25)
                .padding(.horizontal, 30)
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
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(logs) { log in
                            let _ = print(log.logId as String? ?? "")
                            LogItemView(log: LogType.log(log))
                                .accessibility(identifier: "logItem_\(log.logId ?? "")")
                        }
                    }
                    .padding(.horizontal)
                }
            } else if selectedTab == "Friends" {
                HStack {
                    
                    Text("Friends")
                        .font(.system(size: 30))
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Code for button to add a friend
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
                            }
                            
                            ForEach(friendRequests, id: \.self) { friendID in FriendRequestList(FriendRequestID: friendID)
                                    .padding(.horizontal)
                            }
                        }
                        if logRequests.isEmpty == false {
                            HStack {
                                Text("Log Request")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                Spacer()
                            }
                            
                            ForEach(logRequests, id: \.self) { logID in LogRequestList(RequestID: logID)
                                    .padding(.horizontal)
                            }
                        }
                        ForEach(friends) { friendID in FriendList(friendName: friendID.username ?? "")
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }.padding(.top, 80)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
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
        /*FirebaseService.shared.db.collection("logs")
            .whereField("owner.user_id", isEqualTo: userId).whereField("is_visible", isEqualTo: true)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    return
                }
                
                do {
                    try snapshot.documentChanges.forEach { diff in
                        if (diff.type) == .added {
                            let newData: LogData = try diff.document.data(as: LogData.self)
                            logs.append(newData)
                        }
                        if (diff.type == .modified) {
                            if let index = logs.firstIndex(where: { $0.logId == diff.document.documentID }) {
                                let newData: LogData = try diff.document.data(as: LogData.self)
                                logs[index] = newData
                            }
                        }
                        if (diff.type == .removed) {
                            logs.removeAll { $0.logId == diff.document.documentID }
                        }
                    }
                } catch {
                    return
                }
            }*/
    }
    private func fetchFriends() {
        DispatchQueue.main.async {
            Task {
                guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                    return
                }
                do {
                    let result = try await FriendRepository.getFriends(userId: userId).get()
                    friends = result
                } catch {
                    print("Error fetching friends: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct FriendList: View {
    let friendName: String
        
        var body: some View {
            Button(action: {
                        // Code for Functionaility
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle") //TEMP friend PFP
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                                        
                            Text(friendName)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
        }

struct FriendRequestList: View {
    let FriendRequestID: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle") //TEMP friend PFP
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            Text("FriendRequestName")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                // Code for Functionaility
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
                }.accessibility(identifier: "Accept Friend Request")
            }
            .padding(.horizontal, 20)
                        
            Button(action: {
                // Functionaility
            }) {
                Image(systemName: "xmark.circle")
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
            }.accessibility(identifier: "Remove Friend Request")
            
        }
    }
}

struct LogRequestList: View {
    let RequestID: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle") //TEMP friend PFP
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            VStack {
                Text("CreatorName")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(RequestID)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            
            Spacer()
            
            Button(action: {
                // Code for Functionaility
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
                }
            }.accessibility(identifier: "Accept Log Request")
            .padding(.horizontal, 20)
                        
            Button(action: {
                // Functionaility
            }) {
                Image(systemName: "xmark.circle")
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }.accessibility(identifier: "Remove Log Request")
            
        }
    }
}
