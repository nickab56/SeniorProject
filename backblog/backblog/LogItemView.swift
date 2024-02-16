import SwiftUI

struct LogItemView: View {
    @StateObject var vm: LogViewModel
    
    init(log: LogType) {
        _vm = StateObject(wrappedValue: LogViewModel(log: log, fb: FirebaseService(), movieService: MovieService()))
    }

    var body: some View {
        ZStack {
            if vm.isLoading {
                Rectangle()
                    .foregroundColor(.gray)
                    .aspectRatio(1, contentMode: .fill)
            } else if let posterURL = vm.posterURL {
                AsyncImage(url: posterURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().foregroundColor(.gray)
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(Rectangle().foregroundColor(.black).opacity(0.3))
                    case .failure:
                        Image("NewLogImage") // Use the local asset as a fallback
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 10)
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipped()
            } else {
                Image("NewLogImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 10)
            }

            VStack {
                let txt = switch vm.log {
                case .localLog(let local):
                    local.name ?? ""
                case .log(let log):
                    log.name ?? ""
                }
                Text(vm.truncateText(txt))
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .cornerRadius(15)
        .onAppear {
            vm.fetchMoviePoster()
        }
    }
}
