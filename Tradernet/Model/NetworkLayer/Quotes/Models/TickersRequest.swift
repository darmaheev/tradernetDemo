import Foundation

struct TickersRequest: Codable {
    var q: TickersRequestQueryParams
    
    init(countTickers: Int) {
        q = TickersRequestQueryParams(countTickers: countTickers)
    }
}

struct TickersRequestQueryParams: Codable {
    var cmd: String
    var params: TickersRequestParams
    
    init(countTickers: Int) {
        cmd = "getTopSecurities"
        params = TickersRequestParams(limit: countTickers)
    }
}

struct TickersRequestParams: Codable {
    var type: String
    var exchange: String
    var gainers: Int
    var limit: Int
    
    init(limit: Int) {
        self.type = "stocks"
        self.exchange = "russia"
        self.gainers = 0
        self.limit = limit
    }
}
