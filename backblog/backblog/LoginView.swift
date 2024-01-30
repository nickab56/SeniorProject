import SwiftUI

struct LoginView: View {
    @Binding var isLoggedInToSocial: Bool
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

                    TextField("Email or Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .accessibility(identifier: "usernameTextField")

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .accessibility(identifier: "passwordSecureField")

                    Button("Log In") {
                        //self.isLoggedInToSocial = true
                        attemptLogin(email: username, password: password)
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
    }
    
    private func attemptLogin(email: String, password: String) {
        // Check if email and password are not empty and formatted correctly
            // Email format
            // Password at least 6 chars long
        // Call login func
            // Check to see if it was successful
        // Return success
    }
}
