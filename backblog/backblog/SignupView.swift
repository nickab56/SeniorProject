// SignupView.swift

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @Binding var isLoggedInToSocial: Bool
    @State private var signupSuccessful = false
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
                        //self.isLoggedInToSocial = true
                        if (username.isEmpty || password.isEmpty || displayName.isEmpty) {
                            // Add text "Please fill all fields"
                        } else {
                            if (password.count < 6) {
                                // Add text "Please enter a password of 6 chars or more
                            } else {
                                // Fields are filled, attempt signup
                                attemptSignup(email: username, password: password, displayName: displayName)
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
            .navigationDestination(isPresented: $isLoggedInToSocial) {
                SocialView()
            }
            .navigationDestination(isPresented: $signupSuccessful) {
                SignupView(isLoggedInToSocial: $isLoggedInToSocial)
            }
    }
    
    private func attemptSignup(email: String, password: String, displayName: String) {
        Task {
            do {
                // Register
                let result = try await FirebaseService.shared.register(email: email, password: password).get()
                
                // Successfully registered, now try to add user to firestore
                _ = try await UserRepository.addUser(userId: result, username: displayName, avatarPreset: 1).get()
                
                signupSuccessful = true
            } catch {
                let _ = print(error)
            }
        }
    }
}
