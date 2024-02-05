import SwiftUI

struct LoginView: View {
    @Binding var isLoggedInToSocial: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var loginMessage = ""
    @State private var messageColor = Color.red

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
                        
                        Text(loginMessage)
                            .foregroundColor(messageColor)
                            .padding()

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
                                loginMessage = "Please fill all fields"
                                messageColor = Color.red
                            } else {
                                if password.count < 6 {
                                    loginMessage = "Password must be at least 6 characters"
                                    messageColor = Color.red
                                } else {
                                    attemptLogin(email: username, password: password)
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

                        NavigationLink(destination: SignupView(isLoggedInToSocial: $isLoggedInToSocial)) {
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
            .navigationDestination(isPresented: $isLoggedInToSocial) {
                SocialView()
            }
    }
    
    private func attemptLogin(email: String, password: String) {
        DispatchQueue.main.async {
            Task {
                do {
                    _ = try await FirebaseService.shared.login(email: email, password: password).get()
                    loginMessage = "Login Successful, redirecting..."
                    messageColor = Color.green
                    
                    // Add a short delay to display the success message before changing the state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // Now change the isLoggedInToSocial to trigger the redirection
                        isLoggedInToSocial = true
                    }
                } catch {
                    loginMessage = "Login Failed: \(error.localizedDescription)"
                    messageColor = Color.red
                }
            }
        }
    }
}
