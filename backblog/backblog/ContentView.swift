import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch the first log entry
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.logid, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LogEntity>
    
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

                if let firstLog = logs.first {
                    VStack(alignment: .leading) {
                        Text("From \(firstLog.logname ?? "Unknown")")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.leading)

                        Image("img_placeholder_poster")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.9)
                    }
                }

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
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.logid, ascending: true)], // Sort in descending order
        animation: .default)
    private var logs: FetchedResults<LogEntity>

    @State private var showingAddLogSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Logs")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    showingAddLogSheet = true
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
                    ForEach(logs, id: \.self) { log in
                        NavigationLink(destination: LogDetailView(log: log)) {
                            LogItemView(log: log)
                        }
                        .padding(10) // Adjust padding if necessary
                    }
                }
                .padding(.horizontal, 20) // Adjust horizontal padding if necessary
            }
        }
        .sheet(isPresented: $showingAddLogSheet) {
            AddLogSheetView(isPresented: $showingAddLogSheet)
        }
    }
}


struct AddLogSheetView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newLogName = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Log Name", text: $newLogName)
                Button("Add Log") {
                    addNewLog()
                    isPresented = false
                }
            }
            .navigationBarTitle("Add New Log", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }

    private func addNewLog() {
        let newLog = LogEntity(context: viewContext)
        newLog.logname = newLogName
        newLog.logid = Int64(UUID().hashValue)

        do {
            try viewContext.save()
        } catch {
            // Handle the error
        }
    }
}



struct LogItemView: View {
    let log: LogEntity

    var body: some View {
        ZStack {
            // Image layer as the base
            Image("img_placeholder_log_batman")
                .resizable()
                .scaledToFill() // Adjust to fill the entire frame
                .frame(width: 150, height: 150) // Increased size of the image
                .clipped() // Clip the image to the bounds of the frame
                .cornerRadius(5)

            // Overlay with black background and text
            VStack {
                Text(log.logname ?? "")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
            }
            .frame(width: 150, height: 150) // Match the frame size to the image
            .background(Color.black.opacity(0.7))
            .cornerRadius(5)
        }
    }
}









struct LogDetailView: View {
    let log: LogEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Details for Log \(log.logname ?? "Unknown")")
            // Add more details about the log here if needed

            Button("Delete Log") {
                deleteLog()
            }
            .foregroundColor(.red)
        }
    }

    private func deleteLog() {
        viewContext.delete(log)

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Dismiss the detail view after deletion
        } catch {
            print("Error deleting log: \(error)")
        }
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
