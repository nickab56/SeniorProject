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
                
                HStack(alignment: .center){
                    VStack(){
                        if (vm.isOwner || vm.isCollaborator) {
                            CollaboratorsView(collaborators: vm.getCollaboratorAvatars())
                            .frame(maxWidth: 80)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        if (vm.movies.count == 1) {
                            Text("\(vm.movies.count) Movie")
                        }
                        else {
                            Text("\(vm.movies.count) Movies")
                        }
                    }
                    Spacer()
                }.padding(.leading, 16)
                    .offset(y: -20)
                
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
                                //.padding()
                                .frame(width: 50, height: 50)
                                //.font(.system(size: 30))
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
                    //.padding(.leading)
                }
                
                VStack(alignment: .leading) {
                    Text(movie.title ?? "N/A")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        //.fontWeight(.bold)
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
            //.overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
}

/**
 View displaying the avatars of log collaborators.
 
 - Parameters:
     - collaborators: An array of avatar image names representing log collaborators.
 */
struct CollaboratorsView: View {
    var collaborators: [String]
    @State private var expanded = false

    var body: some View {
        HStack(spacing: 0) {
            if collaborators.count > 4 && !expanded {
                AvatarView(imageName: collaborators.first ?? "")
                    .overlay(
                        expandButtonOverlay,
                        alignment: .bottomTrailing
                    )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 2) {
                        ForEach(collaborators.indices, id: \.self) { index in
                            AvatarView(imageName: collaborators[index])
                                .overlay(
                                    // Only show condense button if there are more than 4 collaborators
                                    (index == collaborators.count - 1 && collaborators.count > 4) ? condenseButtonOverlay : nil,
                                    alignment: .bottomTrailing
                                )
                        }
                    }
                    //.padding(.leading, 10)
                }
                .frame(height: 45)
            }
        }
        .frame(alignment: .leading)
    }

    /**
     A private method that creates an expand button for the list of collaborators.
     */
    private var expandButtonOverlay: some View {
        Button(action: {
            withAnimation {
                expanded = true
            }
        }) {
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .overlay(Text("+").font(.system(size: 12)).foregroundColor(.white))
        }
        .padding(5)
    }

    /**
     A private method that creates an condense button for the list of collaborators.
     */
    private var condenseButtonOverlay: some View {
        Button(action: {
            withAnimation {
                expanded = false
            }
        }) {
            Circle()
                .fill(Color.gray)
                .frame(width: 20, height: 20)
                .overlay(Text("–").font(.system(size: 12)).foregroundColor(.white))
        }
        .padding(5)
    }
}
