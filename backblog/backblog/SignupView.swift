//
//  SignupView.swift
//  backblog
//
//  Updated by Jake Buhite on 02/09/24.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @ObservedObject var vm: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var displayName = ""

    var body: some View {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                // Card background
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color(hex: "#242b2f"))
                    .shadow(radius: 10)
                    .padding()
                
                VStack {
                    Image("img_placeholder_backblog_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)

                    Text("BackBlog")
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    Text("Create an account to Collaborate")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                    
                    Text(vm.signupMessage)
                        .foregroundColor(vm.messageColor)
                        .padding()

                    TextField("Email or Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .accessibility(identifier: "signupUsernameTextField")

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .accessibility(identifier: "signupPasswordSecureField")

                    TextField("Display Name", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .accessibility(identifier: "signupDisplayNameTextField")

                    Button("Continue") {
                        if username.isEmpty || password.isEmpty || displayName.isEmpty {
                            vm.signupMessage = "Please fill all fields"
                            vm.messageColor = Color.red
                        } else {
                            if password.count < 6 {
                                vm.signupMessage = "Password must be at least 6 characters"
                                vm.messageColor = Color.red
                            } else {
                                vm.attemptSignup(email: username, password: password, displayName: displayName)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                    .accessibility(identifier: "signupContinueButton")
                    Spacer()
                }
                .padding()
            }
            .navigationDestination(isPresented: $vm.isLoggedInToSocial) {
                SocialView()
            }
            .navigationDestination(isPresented: $vm.signupSuccessful) {
                LoginView(vm: vm)
            }
    }
}
