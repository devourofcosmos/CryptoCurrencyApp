import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = CryptoAppViewModel() // Create a new instance of the view model

    var body: some View {
        Home(selectedCoin: "BTC") // Set the default selected coin as Bitcoin (BTC)
            .preferredColorScheme(.dark) // Enable dark mode for the entire app
            .padding(.horizontal) // Add horizontal padding around the content
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Set the background to black
            .environmentObject(viewModel) // Pass the view model to all child views
    }
}

#Preview {
    ContentView() // Preview the ContentView
}
