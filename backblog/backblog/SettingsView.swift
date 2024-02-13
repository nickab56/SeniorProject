//
//  SettingsView.swift
//  backblog
//
//  Created by Joshua Altmeyer on 1/26/24.
//  Updated by Jake Buhite on 2/07/24.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @ObservedObject var vm: SocialViewModel
    
    // Settings Form
    @State private var usernameText: String = ""
    @State private var oldPasswordText: String = ""
    @State private var newPasswordText: String = ""
    @State private var showingAvatarSelection: Bool = false
    
    // Message
    @State private var saveMessage: String = ""
    @State private var messageColor: Color = Color.red
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack{
                    HStack{
                        
                        Text("Settings")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .bold()
                            .padding(.horizontal)
                        
                        Spacer()
                        
                    }
                    
                    HStack(spacing: 50){
                        // Display user's avatar
                        Image(uiImage: UIImage(named: getAvatarId(avatarPreset: vm.avatarSelection)) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        
                        
                        Button(action: {
                            self.showingAvatarSelection = true
                        }) {
                            Text("Change Avatar")
                                .foregroundColor(.white)
                        }
                        .frame(width: 160, height: 50)
                        .background(Color.init(hex: "0x232323"))
                        .cornerRadius(50)
                        .padding(.top, 50)
                    }
                    HStack{
                        Text("Username")
                            .padding(.leading)
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 20))
                        Spacer()
                    }.padding(.top, 10)
                    
                    TextField(vm.userData?.username ?? "Username", text: $usernameText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 15)
                        .padding(.bottom, 10)
                    
                    HStack {
                        Text("Old Password")
                            .padding(.leading)
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 20))
                        Spacer()
                    }
                    SecureField("Enter Old Password", text: $oldPasswordText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 15)
                        .padding(.bottom, 10)
                    
                    HStack {
                        Text("New Password")
                            .padding(.leading)
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 20))
                        
                        Spacer()
                    }
                    SecureField("Enter New Password", text: $newPasswordText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 15)
                    
                    // Status Message
                    Text(saveMessage)
                        .foregroundColor(messageColor)
                        .padding()
                        .accessibility(identifier: "StatusMessage")
                    
                    Button(action: {
                        // Update user
                        vm.updateUser(username: usernameText, newPassword: newPasswordText, password: oldPasswordText)
                    }) {
                        Text("SAVE")
                            .foregroundColor(.white)
                    }
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(50)
                    .padding(.top, 5)
                    
                    Button(action: {
                        vm.logout()
                    }) {
                        Text("LOG OUT")
                            .foregroundColor(.red)
                    }
                    .frame(width: 300, height: 50)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.red, lineWidth: 2)
                    )
                    .padding(.top, 10)
                    
                    Spacer()
                }.padding(.top, 10)
            }
        }
        .sheet(isPresented: $showingAvatarSelection) {
            AvatarSelectionView { selectedAvatarPreset in
                showingAvatarSelection = false
                vm.avatarSelection = selectedAvatarPreset
            }
        }
        .navigationDestination(isPresented: $vm.isUnauthorized) {
            SearchView()
        }
    }
}
