import SwiftUI
import SDWebImageSwiftUI

struct FavoriteCoinsView: View {
    @EnvironmentObject var viewModel: CryptoAppViewModel
    @State private var favoriteCryptos: [CryptoModel] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title for the Favorite Cryptos section
            Text("Favorite Cryptos")
                .font(.title2.bold())
                .foregroundColor(.gray)
                .padding(.horizontal)

            // Scrollable list of favorite cryptocurrencies
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(favoriteCryptos) { coin in
                        HStack {
                            // Display crypto icon with a circular frame
                            AnimatedImage(url: URL(string: coin.image))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .padding(8)
                                .background(Circle().fill(Color.gray.opacity(0.2)))

                            // Show coin details: symbol and current price
                            VStack(alignment: .leading, spacing: 4) {
                                Text(coin.symbol.uppercased())
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("USD \(String(format: "%.2f", coin.current_price))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // Display price change percentage with color indicator
                            HStack {
                                Text("\(coin.price_change > 0 ? "+" : "")\(String(format: "%.2f", coin.price_change))%")
                                    .font(.headline)
                                    .foregroundColor(coin.price_change > 0 ? .green : .red)

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.1))
                                .shadow(radius: 5)
                        )
                        .onTapGesture {
                            // Handle tap to select a specific cryptocurrency
                            viewModel.selectedCoin = coin
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            // Load favorite coins from UserDefaults on appearance
            let favoriteSymbols = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
            favoriteCryptos = viewModel.cryptoCoins?.filter { favoriteSymbols.contains($0.symbol.uppercased()) } ?? []
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteCoinsView()
            .environmentObject(CryptoAppViewModel()) // Inject the CryptoAppViewModel for preview
    }
}
