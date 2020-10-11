import Foundation

// MARK: - QuotesInfoResponse

struct QuotesInfoResponse: Codable {
    let changedQuotes: [QuotesInfo]
    
    enum CodingKeys: String, CodingKey {
        case changedQuotes = "q"
    }
    
}

// MARK: - QuotesInfo

struct QuotesInfo: Codable, Hashable {
    var ticker: String?
    var procentChange: Double?
    var exchangeName: String?
    var stockName: String?
    var lastOrderPrice: Double?
    var change: Double?
    var minStep: Double?
    var isPositive: Bool?
    var updateTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case ticker = "c"
        case procentChange = "pcp"
        case exchangeName = "ltr"
        case stockName = "name"
        case lastOrderPrice = "ltp"
        case change = "chg"
        case minStep = "min_step"
    }
    
}

// MARK: - Equatable

extension QuotesInfo: Equatable {
    static func == (lhs: QuotesInfo, rhs: QuotesInfo) -> Bool {
        return lhs.ticker == rhs.ticker
    }
}

// MARK: - Update

extension QuotesInfo {
    mutating func update(_ newQuotes: QuotesInfo) {
        ticker = newQuotes.ticker ?? ticker
        procentChange = newQuotes.procentChange ?? procentChange
        exchangeName = newQuotes.exchangeName ?? exchangeName
        stockName = newQuotes.stockName ?? stockName
        lastOrderPrice = newQuotes.lastOrderPrice ?? lastOrderPrice
        change = newQuotes.change ?? change
        if let lastOrderPrice = lastOrderPrice, let newLastOrderPrice = newQuotes.lastOrderPrice {
            isPositive = newLastOrderPrice > lastOrderPrice
        } else {
            isPositive = nil
        }
        updateTime = Date()
    }
}
