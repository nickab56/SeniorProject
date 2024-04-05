//
//  LogItemView.swift
//  backblog
//
//  Created by Nick Abegg on 2/4/24.
//  Updated by Jake Buhite on 2/23/24
//
//  Description: Displays a single log item with its related details.
//

import SwiftUI

/**
 Displays a single log item with its related details.
 
 - Parameters:
     - vm: The `LogViewModel` managing the log item's data.
 */
struct LogItemView: View {
    @StateObject var vm: LogViewModel
    
    /**
     Initializes the LogItemView with a LogType instance.
     
     - Parameters:
         - log: The `LogType` instance representing the log item.
     */
    init(log: LogType) {
        _vm = StateObject(wrappedValue: LogViewModel(log: log, fb: FirebaseService(), movieService: MovieService()))
    }

    /**
     The body of `LogItemView` view, responsible for displaying the layout and SwiftUI elements.
     */
    var body: some View {
        ZStack {
            if vm.isLoading {
                Rectangle()
                    .foregroundColor(.gray)
                    .aspectRatio(1.0, contentMode: .fit)
            } else if let posterURL = vm.posterURL {
                AsyncImage(url: posterURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().foregroundColor(.gray)
                    case .success(let image):
                        Rectangle()
                            .frame(width: 175, height: 175)
                            .overlay (
                                image.resizable()
                                    .scaledToFill()
                                    .overlay(Rectangle().foregroundColor(.black).opacity(0.7))
                        )
                    case .failure:
                        Rectangle()
                            .frame(width: 175, height: 175)
                            .overlay(
                                Image("nomovies") // Use the local asset as a fallback
                                    .resizable()
                                    .overlay(Rectangle().foregroundColor(.black).opacity(0.7))
                        )
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipped()
            } else {
                Rectangle()
                    .frame(width: 175, height: 175)
                    .overlay(
                        Image("nomovies")
                            .resizable()
                            .overlay(Rectangle().foregroundColor(.black).opacity(0.7))
                )
            }

            VStack {
                let txt = switch vm.log {
                case .localLog(let local):
                    local.name ?? ""
                case .log(let log):
                    log.name ?? ""
                }
                Text(vm.truncateText(txt))
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .cornerRadius(10)
        .onAppear {
            vm.fetchMoviePoster()
        }
    }
}
