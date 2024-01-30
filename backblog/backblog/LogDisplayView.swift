import SwiftUI
import CoreData

struct LogDisplayView: View {
    let log: LogEntity

    var body: some View {
        VStack(alignment: .leading) {
            Text("From \(log.logname ?? "Unknown")")
                .font(.subheadline)
                .foregroundColor(.gray)
                .bold()
                .padding(.leading)
                .accessibility(identifier: "logNameText")

            Image("img_placeholder_poster")
                .resizable()
                .scaledToFit()
                .cornerRadius(15)
                .padding(.horizontal, 10)
                .accessibility(identifier: "logPosterImage")

            HStack {
                VStack(alignment: .leading) {
                    Text("Tenet") // Placeholder movie title
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()

                    Text("PG-13 · 2020") // Placeholder age rating and release year
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                }
                
                Spacer()

                Button(action: {
                    // Action for the button
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
