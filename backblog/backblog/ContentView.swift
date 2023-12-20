import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    init() {
        configureNavigationBar()
        configureTabBar()
    }

    var body: some View {
        GeometryReader { geometry in
            TabView {
                NavigationView {
                    mainContentView(geometry: geometry)
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
                // Custom Title View
                CustomTitleView(title: "What's Next?")
                    .bold()
                    .padding(.top, geometry.size.height * 0.08)

                // Rest of the content
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                    //.padding(.top, geometry.size.height * 0.2)
                    .padding(.bottom, geometry.size.height * 0.05)

                MyLogsView()
                    .padding(.bottom, 150) // Added bottom padding
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }

    
    struct CustomTitleView: View {
        var title: String
        var body: some View {
            Text(title)
                .font(.largeTitle) // Large title style
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.clear) // Transparent background
        }
    }



    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func configureTabBar() {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()

            // Set the tab bar's background to a grayish-black color
            appearance.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

            // Apply the appearance to the tab bar
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
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
    @State private var logs: [Int] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Logs")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)

                Spacer() // This will push the button to the right

                // Button to add a new log
                Button(action: {
                    // Add a new log to the array
                    logs.append(logs.count + 1)
                }) {
                    Image(systemName: "plus.square.fill.on.square.fill")
                        .foregroundColor(Color(hex: "#1b2731")) // Color for the icon
                }
                .padding(8)
                .background(Color(hex: "#3891e1")) // Background color for the button
                .cornerRadius(8)
            }
            .padding([.top, .leading, .trailing])

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
