//
//  SignupView.swift
//  backblog
//
//  Updated by Jake Buhite on 02/09/24.
//

import SwiftUI
import FirebaseAuth

/**
 Displays the signup view where users can create a new account.

 This view presents a form for new users to sign up by providing their email, password, and display name. It includes validation to ensure that all fields are filled and the password meets the required length. The view uses the `AuthViewModel` to handle the signup process and display relevant messages, such as errors or success notifications.

 - Properties:
    - `vm`: The authentication view model that handles signup operations.
    - `email`: A state variable for the user's email input.
    - `password`: A state variable for the user's password input.
    - `displayName`: A state variable for the user's chosen display name.

 The view includes text fields for user input, a button to trigger the signup process, and navigation links to proceed based on the signup outcome (success or failure).
 */
struct SignupView: View {
    @ObservedObject var vm: AuthViewModel
    @State private var email = ""
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
                    HStack{
                        Image("img_placeholder_backblog_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        VStack(alignment: .leading) {
                            Text("BackBlog")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .bold()
                            
                            Text("Create an account to Collaborate")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.bottom, 20)
                        }.padding(.top, 10)
                    }.padding(.horizontal, -3)
                    
                    Text(vm.signupMessage)
                        .foregroundColor(vm.messageColor)
                        .padding()
                        .accessibilityIdentifier("signupMessage")
                    VStack (spacing: 15) {
                        TextField("Email", text: $email)
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
                    }
                    

                    Button("Continue") {
                        if email.isEmpty || password.isEmpty || displayName.isEmpty {
                            vm.signupMessage = "Please fill all fields"
                            vm.messageColor = Color.red
                        } else {
                            if password.count < 6 {
                                vm.signupMessage = "Password must be at least 6 characters"
                                vm.messageColor = Color.red
                            } else {
                                vm.attemptSignup(email: email, password: password, displayName: displayName)
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
                    
                    NavigationLink(destination: LoginView(vm: vm)) {
                        HStack {
                            Text("Have an account?")
                                .foregroundColor(.gray)
                            Text("Login")
                                .foregroundColor(.blue)
                                .bold()
                                .underline(true)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: $vm.isLoggedInToSocial) {
                SocialView()
            }
            .navigationDestination(isPresented: $vm.signupSuccessful) {
                LoginView(vm: vm)
            }
            .navigationBarBackButtonHidden(true)
    }
}
