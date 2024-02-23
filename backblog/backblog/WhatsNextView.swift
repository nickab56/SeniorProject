//
//  WhatsNextView.swift
//  backblog
//
//  Created by Nick Abegg on 2/18/24.
//  Updated by Jake Buhite on 2/23/23.
//
//  Description: View for displaying the next movie in a log.
//

import SwiftUI
import CoreData

/**
 View for displaying the next movie in a log.
 
 - Parameters:
     - log: The log type containing the next movie.
     - vm: The view model for managing the logs.
 */
struct WhatsNextView: View {
    var log: LogType
    @ObservedObject var vm: LogsViewModel

    /**
     The body of `WhatsNextView` view, responsible for displaying the layout and SwiftUI elements.
     */
    var body: some View {
        VStack(alignment: .leading) {
            Text("From \(vm.nextLogName)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .bold()
                .padding(.leading)
                .accessibility(identifier: "logNameText")

            // Movie Image with Navigation Link
            NavigationLink(destination: MovieDetailsView(movieId: vm.nextMovie ?? "")) {
                vm.halfSheetImage
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .padding(.horizontal, 10)
                    .accessibility(identifier: "logPosterImage")
            }
            .buttonStyle(PlainButtonStyle())

            HStack {
                VStack(alignment: .leading) {
                    Text(vm.movieTitle)
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                        .accessibility(identifier: "WhatsNextTitle")

                    Text(vm.movieDetails)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                        .accessibilityIdentifier("WhatsNextDetails")
                }
                
                Spacer()

                Button(action: {
                    withAnimation {
                        vm.markMovieAsWatched(log: log)
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "#3891e1"))
                }
                .padding(.trailing, 20)
                .accessibility(identifier: "checkButton")
            }
            .padding(.horizontal)
        }
    }
}
