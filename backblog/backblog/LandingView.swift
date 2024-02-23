import SwiftUI
import CoreData

struct LandingView: View {
    @StateObject private var vm: LogsViewModel
    @StateObject private var authViewModel: AuthViewModel

    init() {
        NavConfigUtility.configureNavigationBar()
        NavConfigUtility.configureTabBar()
        _vm = StateObject(wrappedValue: LogsViewModel(fb: FirebaseService(), movieService: MovieService()))
        _authViewModel = StateObject(wrappedValue: AuthViewModel(fb: FirebaseService()))
    }

    var body: some View {
        TabView {
            NavigationStack {
                mainLandingView()
            }
            .tabItem {
                Image(systemName: "square.stack.3d.up")
            }
            .accessibility(identifier: "landingViewTab")

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                    .accessibilityElement(children: .ignore)
            }
            .accessibility(identifier: "searchViewTab")

            NavigationStack {
                if vm.isLoggedInToSocial {
                    SocialView()
                } else {
                    LoginView(vm: authViewModel)
                }
            }
            .tabItem {
                Image(systemName: "person.2.fill")
            }
            .accessibility(identifier: "socialViewTab")
        }
        .accentColor(.white)
        .onAppear {
            UITabBar.appearance().barTintColor = .white
        }
    }

    private func mainLandingView() -> some View {
        ScrollView {
            VStack {
                CustomTitleView(title: "What's Next?")
                    .bold()
                    .padding(.top, UIScreen.main.bounds.height * 0.08)

                if let firstLog = vm.logs.first {
                    if vm.hasWatchNextMovie {
                        // If there are unwatched movies, show the WhatsNextView for the first log
                        WhatsNextView(log: firstLog, vm: vm)
                        .padding(.top, -20)
                    } else {
                        // If there are no unwatched movies, show "All Caught Up" message
                        VStack {
                            Text("All Caught Up!")
                                .font(.title)
                                .foregroundColor(.white)
                                .accessibilityIdentifier("NoNextMovieText")

                            Text("You've watched all the movies in this log.")
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    // If there are no logs, show "No logs available" message
                    Text("No logs available.")
                        .foregroundColor(.gray)
                        .padding()
                }

                MyLogsView(vm: vm)
                    .padding(.bottom, 150)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            vm.fetchLogs()
            vm.loadNextUnwatchedMovie()
        }
    }

}
