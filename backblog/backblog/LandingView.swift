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
    @State private var showingWhatsNextCompleteNotification = false
    
    @State private var showingAddLogSheet = false


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
                    .padding(.top, 100)

                if vm.logs.isEmpty {
                    
                    Image(systemName: "square.stack.3d.up.slash")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color(hex: "#9F9F9F"))
                        .padding(.top, 120)
                    Text("You have no logs")
                        .padding(.top, 30)
                        .bold()
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                    Text("Create a new one below.")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                    
                    
                    Button(action: {
                        showingAddLogSheet = true
                    }) {
                        Text("Create New Log")
                            .foregroundColor(.black)
                            .padding(.horizontal, 100)
                            .padding(.vertical, 15)
                            .background(Color(hex: "#3891E1"))
                            .cornerRadius(30)
                    }.padding(.top, 100)
                    .sheet(isPresented: $showingAddLogSheet) {
                        AddLogSheetView(isPresented: $showingAddLogSheet, logsViewModel: vm)
                    }
                    
                    
                } else if vm.hasWatchNextMovie, let firstLog = vm.priorityLog {
                    WhatsNextView(log: firstLog, showingNotification: $showingWhatsNextCompleteNotification, vm: vm)
                        .padding(.top, -20)
                    
                    MyLogsView(vm: vm)
                        .padding(.bottom, 150)
                        .padding(.top, 15)
                } else {
                    Rectangle()
                        .cornerRadius(10)
                        .frame(height: 202.882)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .foregroundColor(Color(hex: "#232323"))
                        .overlay(
                            VStack(){
                                Image(systemName: "square.stack.3d.up.slash")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(Color(hex: "#9F9F9F"))
                                Text("You're all caught up!")
                                    .padding(.top, 10)
                                    .bold()
                                    .foregroundColor(.white)
                                    .font(.system(size: 25))
                            }
                        )
                    MyLogsView(vm: vm)
                        .padding(.bottom, 150)
                        .padding(.top, 15)
                }
            }
        }
        .overlay(
            Group {
                if showingWhatsNextCompleteNotification {
                    WatchedNotificationView()
                        .transition(.move(edge: .bottom))
                        .padding(.top, 675)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showingWhatsNextCompleteNotification = false
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    EmptyView()
                }
            }
        )
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            vm.fetchLogs()
            vm.refreshPriorityLog()
        }
        .navigationBarBackButtonHidden(true)
    }

    
    struct WatchedNotificationView: View {
        /**
         The body of the `WatchedNotificationsView` view, defining the SwiftUI content.
         */
        var body: some View {
            Text("Movie added to watched")
                .padding()
                .background(Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .zIndex(1) // Ensure the notification view is always on top
                .accessibility(identifier: "AddedToWatchedSwiped")
        }
    }
}
