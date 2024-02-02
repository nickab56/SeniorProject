//
//  SettingsView.swift
//  backblog
//
//  Created by Joshua Altmeyer on 1/26/24.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @State private var usernameText = ""
    @State private var oldPasswordText = ""
    @State private var newPasswordText = ""
    @State private var userData: UserData?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                HStack{
                                        
                    Text("Settings")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                    
                    Spacer()

                }
                
                HStack(spacing: 50){
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    
                    Button(action: {
                        // Code for button to add a friend
                    }) {
                        Text("Change Avatar")
                            .foregroundColor(.white)
                    }
                    .frame(width: 160, height: 50)
                    .background(Color.gray)
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
                    .padding(15)
                
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
                    .padding(15)
                
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
                    .padding(15)
                
                Button(action: {
                    // Code for button to add a friend
                }) {
                    Text("SAVE")
                        .foregroundColor(.white)
                }
                .frame(width: 300, height: 50)
                .background(Color.blue)
                .cornerRadius(50)
                .padding(.top, 5)
                
                Button(action: {
                    // logout()
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
    
    
//    func logout() {
//        do {
//            // move to log in page and clear all logs on landingView
//        } catch {
//            logoutMessage = "Logout Failed
//            messageColor = Color.red
//        }
//    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
