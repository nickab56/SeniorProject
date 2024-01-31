import SwiftUI
import CoreData

struct LandingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LocalLogData.log_id, ascending: true)], animation: .default)
    private var logs: FetchedResults<LocalLogData>

    @State private var isLoggedInToSocial = false

    init() {
        NavConfigUtility.configureNavigationBar()
        NavConfigUtility.configureTabBar()
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
                    LoginView(isLoggedInToSocial: $isLoggedInToSocial)
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
                // Custom title for the main content area.
                CustomTitleView(title: "What's Next?")
                    .bold()
                    .padding(.top, UIScreen.main.bounds.height * 0.08)

                // Display the first log entry if available.
                if let firstLog = logs.first {
                    LogDisplayView(log: firstLog)
                        .padding(.top, -20)
                }

                // View for managing and displaying user logs.
                MyLogsView()
                    .padding(.bottom, 150)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
}
