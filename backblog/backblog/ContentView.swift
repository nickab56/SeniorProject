import SwiftUI
import CoreData

struct LogEntry: Identifiable {
    let id: Int
    let name: String
}


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
    @State private var logs: [LogEntry] = []
    @State private var showingAddLogSheet = false // State for showing the sheet
    @State private var newLogName = "" // State for the new log name

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Logs")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                // Button to add a new log
                Button(action: {
                    showingAddLogSheet = true // Show the sheet
                }) {
                    Image(systemName: "plus.square.fill.on.square.fill")
                        .foregroundColor(Color(hex: "#1b2731"))
                }
                .padding(8)
                .background(Color(hex: "#3891e1"))
                .cornerRadius(8)
            }
            .padding([.top, .leading, .trailing])

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(logs) { log in
                        NavigationLink(destination: LogDetailView(log: log)) {
                            LogItemView(log: log)
                        }
                    }
                }
                .padding(.horizontal)
            }

        }
        .sheet(isPresented: $showingAddLogSheet) {
            // Present the sheet for adding a new log
            AddLogSheetView(isPresented: $showingAddLogSheet, logs: $logs, newLogName: $newLogName)
        }
    }
}

// View for adding a new log
struct AddLogSheetView: View {
    @Binding var isPresented: Bool
    @Binding var logs: [LogEntry] // Updated to LogEntry array
    @Binding var newLogName: String

    var body: some View {
        NavigationView {
            Form {
                TextField("Log Name", text: $newLogName)
                Button("Add Log") {
                    let newLog = LogEntry(id: logs.count + 1, name: newLogName)
                    logs.append(newLog)
                    newLogName = "" // Clear the text field
                    isPresented = false // Dismiss the sheet
                }
            }
            .navigationBarTitle("Add New Log", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}


struct LogItemView: View {
    let log: LogEntry

    var body: some View {
        Text(log.name) // Display the log name
            .frame(width: 100, height: 100)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
    }
}

struct LogDetailView: View {
    let log: LogEntry

    var body: some View {
        Text("Details for Log \(log.name)")
        // Additional details about the log can be added here
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
