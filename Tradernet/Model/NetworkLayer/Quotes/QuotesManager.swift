import Foundation
import PromiseKit

// MARK: - Quotes Listner Protocol

protocol QuotesListener {
    func quotesUpdate(_ quotes: [QuotesInfo])
}

final class QuotesManager: NetworkManager {
    
    var delegates = MulticastDelegate<QuotesListener>()
    
    // MARK: - Configuration
    
    override func controller() -> String {
        return .empty
    }
    private let quotesEventName = "q"
    private let tickersToWatchChangesEventName = "sup_updateSecurities2"
    private let tickerImageUrl = "https://tradernet.ru/logos/get-logo-by-ticker?ticker="
    private let defaultTickersList = ["RSTI","GAZP","MRKZ","RUAL","HYDR","MRKS","SBER","FEES","TGKA","VTBR","ANH.US","VICL.US","BURG.US","NBL.US","YETI.US","WSFS.US","NIO.US","DXC.US","MIC.US","HSBC.US","EXPN.EU","GSK.EU","SH P.EU","MAN.EU","DB1.EU","MUV2.EU","TATE.EU","KGF.EU","MGGT.EU","SGGD.EU"]
}

// MARK: - Public interface

extension QuotesManager {
    func connect(with tickers: [String]?) {
        guard let tickers = tickers ?? defaultTickersList else {
            return
        }
        socket.on(clientEvent: .connect) {data, ack in
            self.socket.emit(self.tickersToWatchChangesEventName, tickers)
        }

        socket.on(quotesEventName) {data, ack in
            if let jsonData = try? JSONSerialization.data(withJSONObject:data[0]),
               let data = try? JSONDecoder().decode(QuotesInfoResponse.self, from: jsonData) {
                self.delegates.invoke {
                    $0.quotesUpdate(data.changedQuotes)
                }
            }
        }

        socket.connect()
    }
    
    func getTopTickers(_ count: Int) -> Promise<[String]> {
        return firstly {
            request("", method: .get, object: TickersRequest(countTickers: count), responseType: TickersResponse.self)
        }.map { $0.tickers }
    }
    
    func getTickerImageUrl(for ticker: String?) -> URL? {
        guard let ticker = ticker else {
            return nil
        }
        return URL(string: "\(tickerImageUrl)\(ticker.lowercased())")
    }
}
