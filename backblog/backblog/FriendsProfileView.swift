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
    
    init(friendId: String) {
        _viewModel = StateObject(wrappedValue: FriendsProfileViewModel(friendId: friendId))
    }
    
    var body: some View {
        return VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    // TODO: Present action sheet
                }) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(25)
                .padding(.horizontal, 10)
                .padding(.top, 10)
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

            
            if selectedTab == "Logs" {
                ScrollView {
                    if (viewModel.logs.count > 0) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(viewModel.logs) { log in
                                LogItemView(log: LogType.log(log))
                                    .accessibility(identifier: "logItem_\(log.logId ?? "")")
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
                            ForEach(viewModel.friends) { friendId in FriendListElement(friendId: friendId.userId ?? "", userId: FirebaseService.shared.auth.currentUser?.uid ?? "", username: friendId.username ?? "", avatarPreset: friendId.avatarPreset ?? 1)
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
        }.padding(.top, 80)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
}
