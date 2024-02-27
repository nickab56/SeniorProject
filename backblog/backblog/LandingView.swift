//
//  LandingView.swift
//  backblog
//
//  Created by Nick Abegg on 2/2/24.
//  Updated by Jake Buhite on 2/23/24.
//
//  Description: View responsible for displaying the landing page of the app and the navigation bar.
//

import SwiftUI
import CoreData

/**
 View for responsible for displaying the landing page of the app and the navigation bar on lauch.
 */
struct LandingView: View {
    @StateObject private var vm: LogsViewModel
    @StateObject private var authViewModel: AuthViewModel

    /**
     Initializes the `LandingView`, configuring the navigation bar and tab bar, and initializing view models.
     */
    init() {
        NavConfigUtility.configureNavigationBar()
        NavConfigUtility.configureTabBar()
        _vm = StateObject(wrappedValue: LogsViewModel(fb: FirebaseService(), movieService: MovieService()))
        _authViewModel = StateObject(wrappedValue: AuthViewModel(fb: FirebaseService()))
    }

    /**
     The body of the 'LandingView' view, defining the SwiftUI content
     */
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

    /**
     Creates the main landing view, displaying the `WhatsNextView` and `MyLogsView` when appropriate.
     */
    private func mainLandingView() -> some View {
        ScrollView {
            VStack {
                CustomTitleView(title: "What's Next?")
                    .bold()
                    .padding(.top, UIScreen.main.bounds.height * 0.08)

                if vm.logs.isEmpty {
                    Text("No logs available.")
                        .foregroundColor(.gray)
                        .padding()
                } else if vm.hasWatchNextMovie, let firstLog = vm.priorityLog {
                    WhatsNextView(log: firstLog, vm: vm)
                        .padding(.top, -20)
                } else {
                    VStack {
                        Text("All Caught Up!")
                            .font(.title)
                            .foregroundColor(.white)
                            .accessibilityIdentifier("NoNextMovieText")

                        Text("You've watched all the movies in this log.")
                            .foregroundColor(.gray)
                    }
                }

                MyLogsView(vm: vm)
                    .padding(.bottom, 150)
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            vm.fetchLogs()
            vm.refreshPriorityLog()
        }
        .navigationBarBackButtonHidden(true)
    }

}
