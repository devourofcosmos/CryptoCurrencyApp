import SwiftUI

// MARK: - Model for Crypto Data
struct CryptoModel: Identifiable, Codable {
    var id: String                  // Crypto's unique ID
    var symbol: String               // Crypto's symbol (e.g., BTC for Bitcoin)
    var name: String                 // Full name of the cryptocurrency
    var image: String                // URL for the crypto's image
    var current_price: Double        // Current price in USD
    var last_updated: String         // When the data was last updated
    var price_change: Double         // 24-hour price change percentage
    var last_7days_price: GraphModel // Data for price changes over the last 7 days
    
    // Custom JSON key mapping
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case current_price
        case last_updated
        case price_change = "price_change_percentage_24h"
        case last_7days_price = "sparkline_in_7d"
    }
}

// MARK: - Model for Graph Data
struct GraphModel: Codable {
    var price: [Double] // List of prices over time
    enum CodingKeys: String, CodingKey {
        case price
    }
}

// URL for fetching crypto data
let apiUrl = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&sparkline=true&price_change_percentage=1m")
