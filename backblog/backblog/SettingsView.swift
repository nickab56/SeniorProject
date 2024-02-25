//
//  SettingsView.swift
//  backblog
//
//  Created by Joshua Altmeyer on 1/26/24.
//  Updated by Jake Buhite on 2/07/24.
//

import SwiftUI
import CoreData

/**
 Displays the settings interface allowing users to update their profile and application settings.

 This view includes options for changing the user's avatar, username, and password. It also provides a logout button and, if applicable, a button to sync local logs to the database. The view uses `SocialViewModel` to interact with user data and handle actions like updating settings or logging out. Notifications for actions such as saving changes or syncing logs are displayed using a custom notification view.

 - Properties:
    - `vm`: An observable object of `SocialViewModel` containing the user's data and methods for updating it.
    - `usernameText`: A state variable for the user's username input.
    - `oldPasswordText`: A state variable for the user's old password input.
    - `newPasswordText`: A state variable for the user's new password input.
    - `showingAvatarSelection`: A state variable controlling the visibility of the avatar selection sheet.
    - `saveMessage`: A state variable for the message displayed after saving changes.
    - `messageColor`: A state variable for the color of the save message text.

 The view is structured within a `ZStack` to layer the content over a gradient background, and a `ScrollView` is used to accommodate content that may exceed the screen size. User input fields and action buttons are styled consistently with the app's theme.
 */
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
                            .accessibilityIdentifier("SettingsProfilePicture")
                        
                        
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
                    
                    if (vm.getLocalLogCount() > 0) {
                        Button(action: {
                            vm.syncLocalLogsToDB()
                        }) {
                            Text("SYNC LOGS")
                                .foregroundColor(.white)
                        }
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(50)
                        .padding(.top, 5)
                    }
                    
                    Button(action: {
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
