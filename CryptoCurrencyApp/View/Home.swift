import SwiftUI
import SDWebImageSwiftUI

struct Home: View {
    @State var selectedCoin: String
    @Namespace var animation
    @StateObject var viewModel: CryptoAppViewModel = CryptoAppViewModel()
    @State private var isFavorited: Bool = false
    @State private var favoriteSymbols: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header with navigation to favorites
                HStack {
                    Spacer()

                    // Button to view favorite coins
                    NavigationLink(destination: FavoriteCoinsView()) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 10)

                // If coins are available, show details of the selected one
                if let coins = viewModel.cryptoCoins, let coin = viewModel.selectedCoin {
                    // Coin information with name, symbol, and favorite button
                    HStack(spacing: 12) {
                        AnimatedImage(url: URL(string: coin.image))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                            .padding(8)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                            .shadow(radius: 2)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(coin.name)
                                    .font(.headline)

                                // Star button to toggle favorite status
                                Image(systemName: isFavorited ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        withAnimation {
                                            toggleFavorite(coin: coin.symbol.uppercased())
                                        }
                                    }
                            }

                            Text(coin.symbol.uppercased())
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)

                    // Horizontal list of coins to select from
                    CustomControl(coins: coins)

                    // Coin price and graph
                    VStack(alignment: .leading, spacing: 16) {
                        // Show the current price
                        Text(coin.current_price.convertToCurrency())
                            .font(.system(size: 32, weight: .bold))
                            .padding(.horizontal, 16)

                        // Show price change with color indicator
                        HStack {
                            Text("\(coin.price_change > 0 ? "+" : "")\(String(format: "%.2f", coin.price_change))%")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background {
                                    Capsule()
                                        .fill(coin.price_change > 0 ? Color.green : Color.red)
                                }

                            Image(systemName: coin.price_change > 0 ? "arrow.up" : "arrow.down")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                                .offset(x: -4)
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Graph showing the last 7 days price
                    GraphView(coin: coin)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.2))
                                .shadow(radius: 5)
                        )
                        .padding(.top, 16)
                } else {
                    // Show a loading indicator while fetching data
                    ProgressView()
                        .tint(Color("LightGreen"))
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            // Load favorite coins from user preferences
            favoriteSymbols = UserDefaults.standard.stringArray(forKey: "favorites") ?? []

            // Check if the current selected coin is favorited
            isFavorited = favoriteSymbols.contains(selectedCoin)

            // Set the selected coin when the view appears
            if let activeCoin = viewModel.cryptoCoins?.first(where: { $0.symbol.uppercased() == selectedCoin }) {
                viewModel.selectedCoin = activeCoin
            }
        }
    }

    // MARK: - Toggle favorite status for a coin
    func toggleFavorite(coin: String) {
        if favoriteSymbols.contains(coin) {
            favoriteSymbols.removeAll { $0 == coin }
            isFavorited = false
        } else {
            favoriteSymbols.append(coin)
            isFavorited = true
        }

        // Save the updated favorites list
        UserDefaults.standard.set(favoriteSymbols, forKey: "favorites")
    }

    // MARK: - Line Graph to show price history
    @ViewBuilder
    func GraphView(coin: CryptoModel) -> some View {
        GeometryReader { _ in
            LineGraph(data: coin.last_7days_price.price, profit: coin.price_change > 0)
        }
        .padding(.vertical, 24)
        .padding(.bottom, 10)

        // Display the current price below the graph
        Text(coin.current_price.convertToCurrency())
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.top, 6)
    }

    // MARK: - Custom control to display coin icons in a horizontal list
    @ViewBuilder
    func CustomControl(coins: [CryptoModel]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(coins) { coin in
                    VStack {
                        // Show coin's logo (icon)
                        AnimatedImage(url: URL(string: coin.image))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(10)
                            .background(selectedCoin == coin.symbol.uppercased() ? Color.blue.opacity(0.3) : Color.clear)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(selectedCoin == coin.symbol.uppercased() ? Color.blue : Color.gray, lineWidth: 2)
                            )

                        // Coin symbol text
                        Text(coin.symbol.uppercased())
                            .font(.caption)
                            .foregroundColor(selectedCoin == coin.symbol.uppercased() ? .white : .gray)
                    }
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedCoin = coin
                            selectedCoin = coin.symbol.uppercased()
                            isFavorited = favoriteSymbols.contains(coin.symbol.uppercased())
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Double Extension for Currency Formatting
extension Double {
    func convertToCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // You can change this to another currency if needed
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
