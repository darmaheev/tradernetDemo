import UIKit
import PromiseKit

final class QuotesListViewController: UITableViewController {
    
    // MARK: - Variables
    
    private var timer: Timer?
    private var quotes: [QuotesInfo] = [] {
        didSet {
            update()
        }
    }
    private lazy var update:() -> Void = self.debounce(delay: Constants.updateDelay) { [weak self] in self?.tableView.reloadData() }
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = String(format: localize("%d QuotesListTitle"), Constants.countQuotes)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchQuotes()
        Services.quotes.delegates.addDelegate(self)
        createTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Services.quotes.delegates.removeDelegate(self)
        cancelTimer()
    }
    
}

// MARK: - Fetch tickers and connect socket

private extension QuotesListViewController {
    func fetchQuotes() {
        firstly {
            Services.quotes.getTopTickers(Constants.countQuotes)
        }.done { tickers in
            Services.quotes.connect(with: tickers)
        }.catch { _ in
            print("Failed to get top securities")
        }
    }
}

// MARK: - Table view data source

extension QuotesListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuotesTableViewCell.reuseIdentifier, for: indexPath) as? QuotesTableViewCell else {
            fatalError("Not find cell with identifier QuotesTableViewCell")
        }
        cell.configure(with: quotes[indexPath.row])
        
        return cell
    }
}

// MARK: - QuotesListener

extension QuotesListViewController: QuotesListener {
    func quotesUpdate(_ quotes: [QuotesInfo]) {
        quotes.forEach {
            if let index = self.quotes.firstIndex(of: $0) {
                self.quotes[index].update($0)
            } else {
                self.quotes.append($0)
            }
        }
    }
    
    
}

// MARK: - Timer

private extension QuotesListViewController {
    func createTimer() {
        if timer == nil {
            let timer = Timer(timeInterval: Constants.timerInterval,
                              target: self,
                              selector: #selector(updateTimer),
                              userInfo: nil,
                              repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = Constants.timerTolerance
            
            self.timer = timer
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    func updateTimer() {
        guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else {
            return
        }
        let currentTime = Date()
        
        for indexPath in visibleRowsIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? QuotesTableViewCell,
               let lastUpdateTime = quotes[indexPath.row].updateTime,
               cell.appearanceIsHighlighted == true,
               Int(currentTime.timeIntervalSince(lastUpdateTime)) > Constants.highlitedTime {
                cell.setAppearance(.normal)
            }
        }
    }
}


// MARK: - Debounceable

extension QuotesListViewController: Debounceable { }

// MARK: - Constants

private extension QuotesListViewController {
    struct Constants {
        static let countQuotes: Int = 30
        static let highlitedTime: Int = 1
        static let updateDelay: TimeInterval = 0.3
        static let timerInterval: TimeInterval = 1.0
        static let timerTolerance: TimeInterval = 0.1
    }
}
