import SwiftUI
import CoreData

struct WhatsNextView: View {
    var log: LogType  // Assuming you're passing the specific log for "What's Next"
    @ObservedObject var vm: LogsViewModel

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
