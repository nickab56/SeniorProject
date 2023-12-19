import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    init() {
        configureNavigationBar()
    }

    var body: some View {
        GeometryReader { geometry in
            TabView {
                NavigationView {
                    mainContentView(geometry: geometry)
                    .navigationTitle("What's Next?")
                    .navigationBarTitleDisplayMode(.large)
                }
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
                }
                
                NavigationView {
                    SearchView()
                    .navigationTitle("Search")
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
                
                NavigationView {
                    SocialView()
                    .navigationTitle("Social")
                }
                .tabItem {
                    Image(systemName: "person.2.fill")
                }
            }
            .accentColor(.white)
        }
        .onAppear {
            UITabBar.appearance().barTintColor = .white
        }
    }

    private func mainContentView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack {
                // Placeholder image directly under the navigation title
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                    .padding(.top, geometry.size.height * 0.2)
                    .padding(.bottom, geometry.size.height * 0.05) // Adjust this value as needed

                // 'My Logs' section
                MyLogsView()
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .edgesIgnoringSafeArea(.all)
    }


    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct ImagePlaceholderView: View {
    var geometry: GeometryProxy

    var body: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
            .padding(.bottom, geometry.size.height * 0.5)
    }
}

struct MovieListView: View {
    var body: some View {
        Text("Movies List")
    }
}

struct MyLogsView: View {
    // Sample data for logs
    let logs = Array(1...25) // Assuming 20 log items for demonstration

    var body: some View {
        VStack(alignment: .leading) {
            Text("My Logs")
                .padding()
                .font(.system(size: 24))
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(logs, id: \.self) { log in
                        NavigationLink(destination: LogDetailView(logID: log)) {
                            LogItemView(logID: log)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct LogItemView: View {
    let logID: Int

    var body: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100) // Adjust size as needed
            .background(Color.gray.opacity(0.3)) // Placeholder styling
            .cornerRadius(10)
    }
}

struct LogDetailView: View {
    let logID: Int

    var body: some View {
        Text("Details for Log \(logID)")
            // Customize this view to show the details of each log
    }
}

struct SearchView: View {
    var body: some View {
        ZStack {
            Text("Search View")
        }
    }
}

struct SocialView: View {
    var body: some View {
        ZStack {
            Text("Social View")
        }
    }
}

// Extension to allow hex color initialization
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000ff) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
