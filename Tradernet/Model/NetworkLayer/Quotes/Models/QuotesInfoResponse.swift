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
    var changedType: ChangedType = .none
    var updateTime: Date?
    var needUpdate: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case ticker = "c"
        case procentChange = "pcp"
        case exchangeName = "ltr"
        case stockName = "name"
        case lastOrderPrice = "ltp"
        case change = "chg"
        case minStep = "min_step"
    }
    
    enum ChangedType {
        case positive
        case negative
        case none
    }
    
    init(ticker: String) {
        self.ticker = ticker
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
        change = newQuotes.change ?? change
        if let lastOrderPrice = lastOrderPrice, let newLastOrderPrice = newQuotes.lastOrderPrice {
            changedType = (newLastOrderPrice > lastOrderPrice)
                ? .positive
                : (newLastOrderPrice < lastOrderPrice) ? .negative : .none
            needUpdate = true
        } else {
            changedType = .none
            needUpdate = lastOrderPrice != newQuotes.lastOrderPrice
        }
        lastOrderPrice = newQuotes.lastOrderPrice ?? lastOrderPrice
        updateTime = Date()
    }
    
    mutating func updated() {
        needUpdate = false
    }
}
