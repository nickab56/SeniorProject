import SwiftUI

struct LoginView: View {
    @Binding var isLoggedInToSocial: Bool
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Existing background
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                // Card background with more padding to shrink it
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color(hex: "#23272d"))
                    .shadow(radius: 10)
                    .padding(geometry.size.width * 0.05) // Increase padding here to shrink the card

                VStack {
                    // Company logo placeholder
                    Image("img_placeholder_backblog_logo") // Replace with your logo image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)

                    // App name
                    Text("BackBlog")
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    // Login instruction
                    Text("Login to Collaborate")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)

                    // Username/email input field
                    TextField("Email or Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)

                    // Password input field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Login button
                    Button("Log In") {
                        self.isLoggedInToSocial = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()

                    // Signup redirection link
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
}
