// SignupView.swift

import SwiftUI

struct SignupView: View {
    @Binding var isLoggedInToSocial: Bool
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
                    self.isLoggedInToSocial = true
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
        .navigationBarTitle("Signup", displayMode: .large)
    }
    
    private func attemptLogin(email: String, password: String) {
        // Check if email and password are not empty and formatted correctly
            // Email format
            // Password at least 6 chars long
        // Call register func
            // Check to see if it was successful
        // Call UserRepository.addUser(userId: <#T##String#>, username: <#T##String#>, avatarPreset: <#T##Int#>)
            // Check to see if it was successful
        // Return success
    }
}
