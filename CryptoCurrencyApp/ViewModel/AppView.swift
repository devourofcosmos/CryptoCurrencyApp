import SwiftUI

class CryptoAppViewModel: ObservableObject {
    @Published var cryptoCoins: [CryptoModel]?  // List of fetched cryptocurrencies
    @Published var selectedCoin: CryptoModel?   // Currently selected cryptocurrency
    @Published var fetchError: String?          // Error message, if data fetching fails
    @Published var favoritesList: [CryptoModel] = []  // List of favorite cryptocurrencies
    
    // Time range defaults to 7 days
    @Published var selectedTimeRange: String = "7D"

    // Initialize the view model and fetch the crypto data
    init() {
        Task {
            await loadCryptoData()
        }
    }

    // MARK: - Fetch Crypto Data based on the selected time range
    func loadCryptoData() async {
        // Adjust API URL parameters based on selected time range
        let timeRangeParameter: String
        switch selectedTimeRange {
        case "24H":
            timeRangeParameter = "1"
        case "1M":
            timeRangeParameter = "30"
        default:
            timeRangeParameter = "7" // Default to 7 days
        }
        
        // Construct the API URL
        guard let apiUrl = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&sparkline=true&price_change_percentage=\(timeRangeParameter)") else {
            DispatchQueue.main.async {
                self.fetchError = "Invalid API URL."
            }
            return
        }

        // Fetch and decode the cryptocurrency data
        do {
            let (data, response) = try await URLSession.shared.data(from: apiUrl)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedData = try JSONDecoder().decode([CryptoModel].self, from: data)
                await MainActor.run {
                    self.cryptoCoins = decodedData
                    self.selectedCoin = decodedData.first  // Set the first coin as the default
                    if decodedData.isEmpty {
                        self.fetchError = "No available coin data."
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.fetchError = "Failed to fetch data. HTTP Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)"
                }
            }
        } catch {
            print("Encountered error: \(error)")
            DispatchQueue.main.async {
                self.fetchError = "Error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Add or remove a cryptocurrency from the favorites list
    func updateFavoriteList(for coin: CryptoModel) {
        if let index = favoritesList.firstIndex(where: { $0.id == coin.id }) {
            favoritesList.remove(at: index)  // Remove from favorites if it's already there
        } else {
            favoritesList.append(coin)  // Add to favorites if it's not there yet
        }
    }
}
