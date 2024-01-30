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
import CoreData

struct SocialView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.logid, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LogEntity>

    @State private var selectedTab = "Logs"

    var body: some View {
        VStack {
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
            // Spacer to push content down
            HStack {
                // Profile section
                Image(systemName: "person.crop.circle") // Using system symbol for profile picture
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60) // Size of the profile picture
                
                Text("Username") // Placeholder for user's name
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

            // Grid display based on selected tab
            if selectedTab == "Logs" {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(logs, id: \.self) { log in
                            LogItemView(log: log)
                                .accessibility(identifier: "logItem_\(log.logid)")
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
                        ForEach(userFriends, id: \.self) { friendID in FriendList(friendName: friendID)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }.padding(.top, 80)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        
        var userFriends: [String] {
                // TEMP need friends ID
                return ["nick", "jake", "TOM", "John"] // Sample data
            }
        var friendRequests: [String] {
                // TEMP need friends ID
                return ["nick", "jake", "TOM", "John"] // Sample data
            }
        var logRequests: [String] {
                // TEMP need friends ID
                return ["Log1", "Log2", "Log3", "Log4"] // Sample data
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
