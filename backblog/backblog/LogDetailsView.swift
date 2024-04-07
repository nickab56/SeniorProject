//
//  LogDetailsView.swift
//  backblog
//
//  Created by Nick Abegg on 2/2/24.
//  Updated by Jake Buhite on 2/23/24.
//
//  Description: View responsible for the details of a log, including its movies and collaborators.
//

import SwiftUI
import CoreData

/**
 View displaying the details of a log, including its movies and collaborators
 
 - Parameters:
     - log: A log wrapped in `LogType`.
     - dismiss: The environment variable for dismissing the view.
     - vm: The view model managing log-related data and operations.
 */
struct LogDetailsView: View {
    let log: LogType
    @Environment(\.dismiss) var dismiss
    @State private var editCollaboratorSheet = false
    @StateObject var vm: LogViewModel
    
    @State private var showingSearchAddToLogView = false
    
    @State private var editLogSheet = false
    
    @State private var showingShuffleConfirmation = false
    
    @State private var showingCollaboratorsListView = false
    
    /**
     Initializes the `LogDetailsView`, initializing the `LogViewModel`.
     
     - Parameters:
         - log: The `LogType` of the log.
     */
    init(log: LogType) {
        self.log = log
        _vm = StateObject(wrappedValue: LogViewModel(log: log, fb: FirebaseService(), movieService: MovieService()))
    }

    /**
     The body of the `LogDetailsView` view, defining the SwiftUI content.
     */
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack{
                    CustomTitleView(title: "\(vm.getLogName())")
                        .bold()
                    
                    Spacer()
                }
                
                if !vm.collaborators.isEmpty {
                    Button("View Collaborators") {
                        showingCollaboratorsListView = true
                    }
                    .foregroundColor(.blue)
                    .padding(.trailing, 200)
                    .padding(.bottom, 25)
                }
                
                HStack {
                    if (vm.isOwner && !vm.isLocalLog()) {
                        Button(action: {
                            editCollaboratorSheet = true
                        }) {
                            Image(systemName: "person.badge.plus")
                                .padding()
                                .font(.system(size: 25))
                        }
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .accessibilityIdentifier("editCollabButton")
                    }
                    
                    if (vm.isCollaborator || vm.isOwner) {
                        Button(action: {
                            editLogSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .padding()
                                .font(.system(size: 25))
                        }
                        .accessibilityIdentifier("editLogButton")
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .sheet(isPresented: $editLogSheet) {
                            EditLogSheetView(isPresented: $editLogSheet, vm: vm, onLogDeleted: {
                                dismiss()
                            })
                        }
                        .transition(.slide)
                        
                        Spacer()
                        
                        Button(action: {
                            showingShuffleConfirmation = true
                        }) {
                            Image(systemName: "shuffle")
                                .padding()
                                .font(.system(size: 25))
                        }
                        .accessibilityIdentifier("shuffleLogButton")
                        .background(Color.clear)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        NavigationLink(destination: SearchAddToLogView(log: vm.log), isActive: $showingSearchAddToLogView) {
                            EmptyView() // Hidden NavigationLink
                        }

                        Button(action: {
                            showingSearchAddToLogView = true // This triggers the navigation
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        .background(Color.clear)
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                }
                .padding(.top, -20)
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
                
                
                if vm.movies.isEmpty && vm.watchedMovies.isEmpty {
                    Text("No movies added to this log yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        if !vm.movies.isEmpty {
                            ForEach(vm.movies, id: \.0.id) { (movie, halfSheetPath) in
                                MovieRow(movie: movie, halfSheetPath: halfSheetPath, log: vm.log)
                                    .listRowBackground(Color.clear)
                                    .textCase(nil)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: vm.canSwipeToMarkWatchedUnwatched()) {
                                        if vm.canSwipeToMarkWatchedUnwatched() {
                                            Button {
                                                vm.markMovieAsWatched(movieId: movie.id ?? 0)
                                            } label: {
                                                Label("Watched", systemImage: "checkmark.circle.fill")
                                            }
                                            .tint(.blue)
                                        }
                                    }
                            }
                        }

                        Section(header: Text("Watched").foregroundColor(.white).accessibility(identifier: "WatchedSectionHeader")) {
                            ForEach(vm.watchedMovies, id: \.0.id) { (movie, halfSheetPath) in
                                MovieRow(movie: movie, halfSheetPath: halfSheetPath, log: vm.log)
                                    .listRowBackground(Color.clear)
                                    .textCase(nil)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: vm.canSwipeToMarkWatchedUnwatched()) {
                                        if vm.canSwipeToMarkWatchedUnwatched() {
                                            Button {
                                                vm.markMovieAsUnwatched(movieId: movie.id ?? 0)
                                            } label: {
                                                Label("Unwatched", systemImage: "arrow.uturn.backward.circle.fill")
                                            }
                                            .tint(.blue)
                                        }
                                    }

                            }
                        }

                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                }


            }
            if vm.showingWatchedNotification {
                WatchedNotificationView()
                    .transition(.move(edge: .bottom))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 375)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                vm.showingWatchedNotification = false
                            }
                        }
                    }
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: vm.showingWatchedNotification)
        .onAppear {
            switch (vm.log) {
            case .log(_):
                break
            case .localLog(_):
                vm.fetchMovies()
            }
            if (vm.getUserId() != nil) {
                vm.getOwnerData()
                vm.getFriends()
                vm.getCollaborators()
            }
        }
        .sheet(isPresented: $editCollaboratorSheet) {
            EditCollaboratorSheetView(isPresented: $editCollaboratorSheet, vm: vm)
        }
        .alert("Shuffle Unwatched Movies", isPresented: $showingShuffleConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Shuffle", role: .destructive) {
                withAnimation {
                    vm.shuffleUnwatchedMovies()
                }
            }
        } message: {
            Text("This will randomly rearrange the unwatched movies in your log. Do you want to proceed?")
        }
        NavigationLink(destination: CollaboratorsListView(collaborators: vm.collaborators, currentUser: vm.ownerData), isActive: $showingCollaboratorsListView) { EmptyView() }
    }
    
    /**
     View displaying a notification when a movie is added to the "watched" list.
     */
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

/**
 View representing a row for displaying a movie within a log.
 
 - Parameters:
     - movie: The `MovieData` to display.
     - halfSheetPath: The path for the movie's half-sheet details.
 */
struct MovieRow: View {
    let movie: MovieData
    let halfSheetPath: String
    let log: LogType

    /**
     The body of the `MovieRow` view, defining the SwiftUI content.
     */
    var body: some View {
        NavigationLink(destination: MovieDetailsView(movieId: String(movie.id ?? 0), isComingFromLog: true, log: log)) {
            HStack {
                if let url = URL(string: halfSheetPath) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 145, height: 90)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text(movie.title ?? "N/A")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .accessibility(identifier: "LogDetailsMovieTitle")
                }
            }
            .padding(.vertical, 5)
        }
    }
}

/**
 View representing an avatar image
 
 - Parameters:
     - imageName: The name of the asset to display.
 */
struct AvatarView: View {
    var imageName: String

    /**
     The body of the `AvatarView` view, defining the SwiftUI content.
     */
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 35, height: 35)
            .clipShape(Circle())
    }
}

/**
 View displaying the avatars of log collaborators.
 
 - Parameters:
     - collaborators: An array of avatar image names representing log collaborators.
 */
struct CollaboratorsListView: View {
    let collaborators: [UserData]
    let currentUser: UserData?

    
    // Note: Not sure why the background is black even when applying the gradient. It is good enough for now but it would look better if
    // it had the normal gradient used in the app...
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            List(collaborators) { collaborator in
                NavigationLink(destination: FriendsProfileView(friendId: collaborator.userId ?? "", user: currentUser)) {
                    CollaboratorRow(collaborator: collaborator)
                }
            }
            .background(Color.clear)
            .navigationBarTitle("Collaborators")
        }
    }
}

struct CollaboratorRow: View {
    let collaborator: UserData

    var body: some View {
        HStack {
            AvatarView(imageName: getAvatarId(avatarPreset: collaborator.avatarPreset ?? 1))
                .padding(4)
            Text(collaborator.username ?? "Unknown User")
                .padding(.leading, 8)
        }
    }

    private func getAvatarId(avatarPreset: Int) -> String {
        return "avatar\(avatarPreset)"
    }
}

