import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext


    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 6) {
                Text("What's Next?")
                    .font(.largeTitle)
                    .multilineTextAlignment(.leading)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, -5.0)

                Image("img_placeholder_poster")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: CGFloat.infinity)
                    .cornerRadius(3.0)
                    .padding(.horizontal, 5)

                // Movie title, age rating, release year, and check button
                HStack {
                    VStack(alignment: .leading) {
                        Text("Tenet") // Placeholder movie title
                            .font(.title) // Larger font for the movie title
                            .foregroundColor(.white)

                        Text("PG-13 · 2020") // Placeholder age rating and release year
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer() // This will push the button to the right

                    // Modified check button
                    Button(action: {
                        // Action for the button
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(hex: "#3891e1"))
                    }
                    .padding(.trailing, 20) // Added padding to the right of the button
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
