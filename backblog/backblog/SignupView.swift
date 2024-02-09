// SignupView.swift

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @Binding var isLoggedInToSocial: Bool
    @State private var signupSuccessful = false
    @State private var username = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var signupMessage = ""
    @State private var messageColor = Color.red

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
                    
                    Text(signupMessage)
                        .foregroundColor(messageColor)
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
                            signupMessage = "Please fill all fields"
                            messageColor = Color.red
                        } else {
                            if password.count < 6 {
                                signupMessage = "Password must be at least 6 characters"
                                messageColor = Color.red
                            } else {
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
                // Check if username already exists
                let exists = try await UserRepository.usernameExists(username: displayName).get()
                
                if (exists) {
                    signupMessage = "Username already exists"
                    messageColor = Color.red
                    return
                }
                
                // Register
                let result = try await FirebaseService.shared.register(email: email, password: password).get()
                
                // Store additional user data in firestore
                _ = try await UserRepository.addUser(userId: result, username: displayName, avatarPreset: 1).get()
                
                // Update status
                signupSuccessful = true
                signupMessage = "Signup Successful"
                messageColor = Color.green
            } catch {
                signupMessage = "Signup Failed: \(error.localizedDescription)"
                messageColor = Color.red
            }
        }
    }
}
