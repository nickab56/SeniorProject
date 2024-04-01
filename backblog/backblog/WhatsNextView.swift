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
    @Binding var showingNotification: Bool
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
            Rectangle()
                .frame(height: 202.882)
                .overlay{
                    NavigationLink(destination: MovieDetailsView(movieId: vm.nextMovie ?? "", isComingFromLog: true, log: log)) {
                        vm.halfSheetImage
                            .resizable()
                            .scaledToFill()
                            .accessibility(identifier: "logPosterImage")
                            .clipped()
                    }
                    .clipped()
                    .buttonStyle(PlainButtonStyle())
                }
                .cornerRadius(10)
                .clipped()
                .padding(.horizontal, 16)

            HStack {
                VStack(alignment: .leading) {
                    Text(vm.movieTitle)
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .accessibility(identifier: "WhatsNextTitle")

                    Text(vm.movieDetails)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                        .accessibilityIdentifier("WhatsNextDetails")
                }
                
                Spacer()
                
                VStack(){
                    Button(action: {
                        withAnimation {
                            vm.markMovieAsWatched(log: log)
                            showingNotification = true
                            
                            // Trigger medium-sized haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.prepare()
                            generator.impactOccurred() // Trigger the haptic feedback
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(hex: "#3891e1"))
                    }
                    .accessibility(identifier: "checkButton")
                }
            }
            .padding(.horizontal)
        }
    }
}
