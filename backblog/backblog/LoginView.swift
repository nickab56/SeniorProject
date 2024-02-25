//
//  LoginView.swift
//  backblog
//
//  Updated by Jake Buhite on 02/09/24.
//

import SwiftUI

/**
 Presents the login interface for existing users to access their account.

 This view contains input fields for the username (or email) and password, a login button to authenticate the user, and a link to the signup view for new users. It utilizes the `AuthViewModel` to manage the login process, including validation of input fields and displaying messages for successful or failed login attempts.

 - Properties:
    - `vm`: The authentication view model that facilitates the login process.
    - `username`: A state variable for storing the user's inputted username or email.
    - `password`: A state variable for storing the user's inputted password.

 The view layout adapts to the device's screen size using `GeometryReader`, and the background is styled with a linear gradient. Upon successful login, the view navigates to the `SocialView`.
 */
struct LoginView: View {
    @ObservedObject var vm: AuthViewModel
    @State private var username = ""
    @State private var password = ""

    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                    
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color(hex: "#23272d"))
                        .shadow(radius: 10)
                        .padding(geometry.size.width * 0.05)

                    VStack {
                        Image("img_placeholder_backblog_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)

                        Text("BackBlog")
                            .font(.largeTitle)
                            .foregroundColor(.white)

                        Text("Login to Collaborate")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                        
                        Text(vm.loginMessage)
                            .foregroundColor(vm.messageColor)
                            .padding()
                            .accessibilityIdentifier("loginMessage")

                        TextField("Email or Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .autocapitalization(.none)
                            .accessibility(identifier: "usernameTextField")
                            .keyboardType(UIKeyboardType.emailAddress)

                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .accessibility(identifier: "passwordSecureField")

                        Button("Log In") {
                            if username.isEmpty || password.isEmpty {
                                vm.loginMessage = "Please fill all fields"
                                vm.messageColor = Color.red
                            } else {
                                if password.count < 6 {
                                    vm.loginMessage = "Password must be at least 6 characters"
                                    vm.messageColor = Color.red
                                } else {
                                    vm.attemptLogin(email: username, password: password)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                        .accessibility(identifier: "loginButton")

                        NavigationLink(destination: SignupView(vm: vm)) {
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.gray)
                                Text("Signup")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $vm.isLoggedInToSocial) {
                SocialView()
            }
            .navigationBarBackButtonHidden(true)
    }
}
