import SwiftUI
import CoreData

struct LandingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocalLogData.orderIndex, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LocalLogData>
    
    @StateObject private var logsViewModel = LogsViewModel()
    @StateObject private var authViewModel: AuthViewModel
    @State private var isLoggedInToSocial = false

    init() {
        NavConfigUtility.configureNavigationBar()
        NavConfigUtility.configureTabBar()
        _authViewModel = StateObject(wrappedValue: AuthViewModel())
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
                if isLoggedInToSocial {
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

                if let firstLog = logs.first {
                                // Determine if there are any unwatched movies in the first log
                                let unwatchedMovies = firstLog.movie_ids

                                if let unwatchedMovies = unwatchedMovies, !unwatchedMovies.isEmpty {
                                    // If there are unwatched movies, show the WhatsNextView for the first log
                                    WhatsNextView(log: firstLog, vm: logsViewModel)
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
                                    //.padding(.top, UIScreen.main.bounds.height * 0.1) // Adjust padding as needed
                                }
                            } else {
                                // If there are no logs, show "No logs available" message
                                Text("No logs available.")
                                    .foregroundColor(.gray)
                                    .padding()
                            }


                // Pass LogsViewModel to MyLogsView
                MyLogsView(logsViewModel: logsViewModel)
                    .padding(.bottom, 150)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }

}
