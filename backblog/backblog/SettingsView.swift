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
    @Binding var userData: UserData?
    
    @State private var usernameText: String = ""
    @State private var oldPasswordText: String = ""
    @State private var newPasswordText: String = ""
    @State private var avatarSelection: Int
    @State private var showingAvatarSelection: Bool = false
    @State private var isUnauthorized = false
    @State private var saveMessage: String = ""
    @State private var messageColor: Color = Color.red
    
    init(userData: Binding<UserData?>) {
        _userData = userData
        _avatarSelection = State(initialValue: userData.wrappedValue?.avatarPreset ?? 1)
    }
    
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
                        Image(uiImage: UIImage(named: getAvatarId(avatarPreset: avatarSelection)) ?? UIImage())
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
                    
                    TextField(userData?.username ?? "Username", text: $usernameText)
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
                    
                    Button(action: {
                        // Update user
                        updateUser(username: usernameText, newPassword: newPasswordText, password: oldPasswordText)
                    }) {
                        Text("SAVE")
                            .foregroundColor(.white)
                    }
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(50)
                    .padding(.top, 5)
                    
                    Button(action: {
                        logout()
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
                self.showingAvatarSelection = false
                self.avatarSelection = selectedAvatarPreset
            }
        }
        .navigationDestination(isPresented: $isUnauthorized) {
            SearchView()
        }
    }
    
    private func updateUser(username: String, newPassword: String, password: String) {
        DispatchQueue.main.async {
            Task {
                do {
                    guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                        isUnauthorized = true
                        return
                    }

                    // Check if password field is empty
                    if (!password.isEmpty) {
                        if (!username.isEmpty || !newPassword.isEmpty || avatarSelection != userData?.avatarPreset) {
                            var updates: [String: Any] = [:]
                            
                            // Add updated fields
                            if (!username.isEmpty) {
                                updates["username"] = username
                            }
                            if (!newPassword.isEmpty) {
                                updates["password"] = password
                            }
                            if (avatarSelection != userData?.avatarPreset) {
                                updates["avatar_preset"] = avatarSelection
                            }
                            
                            // Call update user
                            _ = try await UserRepository.updateUser(userId: userId, password: password, updateData: updates).get()
                            
                            // Successful, update userData
                            userData = try await UserRepository.getUser(userId: userId).get()
                            
                            saveMessage = "Successfully updated settings!"
                            messageColor = Color.green
                        } else {
                            // No changes were made
                            saveMessage = "Please make changes before saving."
                            messageColor = Color.red
                        }
                    } else {
                        // Password field is empty
                        saveMessage = "Please enter your current password."
                        messageColor = Color.red
                    }
                } catch {
                    saveMessage = "Error, please try again later."
                    messageColor = Color.red
                }
            }
        }
    }
    
    private func logout() {
        DispatchQueue.main.async {
            Task {
                do {
                    guard let _ = FirebaseService.shared.auth.currentUser?.uid else {
                        isUnauthorized = true
                        return
                    }

                    _ = try FirebaseService.shared.logout().get()
                    
                    // Logout successful
                    isUnauthorized = false
                } catch {
                    saveMessage = "Error, please try logging out later."
                    messageColor = Color.red
                }
            }
        }
    }
}
