// SignupView.swift

import SwiftUI

struct SignupView: View {
    @Binding var isLoggedInToSocial: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var displayName = ""

    var body: some View {
        ZStack {
            // Reuse the background from LoginView
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Card background
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color(hex: "#242b2f"))
                .shadow(radius: 10)
                .padding()
            
            VStack {
                // Company logo placeholder
                Image("img_placeholder_backblog_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)

                // App name
                Text("BackBlog")
                    .font(.largeTitle)
                    .foregroundColor(.white)

                // Instruction text for signup
                Text("Create an account to Collaborate")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                // Email or Username input field
                TextField("Email or Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)

                // Password input field
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Display Name input field
                TextField("Display Name", text: $displayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)

                // Continue button
                Button("Continue") {
                    self.isLoggedInToSocial = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("Signup", displayMode: .large)
    }
}
