import SwiftUI
import CoreData

struct LogDetailsView: View {
    let log: LogEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var movieTitles: [String] = []

    var body: some View {
        VStack {
            Text("Details for Log: \(log.logname ?? "Unknown")")
                .font(.title)
                .padding()
                .accessibility(identifier: "logDetailsText")

            if movieTitles.isEmpty {
                Text("No movies added to this log yet.")
                    .foregroundColor(.gray)
            } else {
                List(movieTitles, id: \.self) { title in
                    Text(title)
                        .foregroundColor(.black)
                }
            }

            Button("Delete Log") {
                deleteLog()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(10)
            .accessibility(identifier: "deleteLogButton")
        }
        .onAppear {
            fetchMovieTitles()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }

    private func fetchMovieTitles() {
        guard let movieIdsString = log.movieIds, !movieIdsString.isEmpty else { return }
        let movieIds = movieIdsString.split(separator: ",").map { String($0) }

        movieTitles = [] // Reset movie titles list

        for idString in movieIds {
            guard let id = Int(idString) else { continue }
            NetworkManager.shared.fetchMovieById(id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let movieDetail):
                        self.movieTitles.append(movieDetail.title)
                    case .failure(let error):
                        print("Error fetching movie by ID: \(error.localizedDescription)")
                    }
                }
            }
        }
    }


    private func deleteLog() {
        viewContext.delete(log)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting log: \(error.localizedDescription)")
            // Optionally, handle the error by showing an alert to the user
        }
    }
}
