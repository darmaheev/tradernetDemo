import UIKit
import Kingfisher

final class QuotesTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: QuotesTableViewCell.self)
    
    // MARK: - Outlets

    @IBOutlet private weak var container: UIStackView!
    @IBOutlet private weak var firstLine: UIStackView!
    @IBOutlet private weak var secondLine: UIStackView!
    @IBOutlet private weak var stockImage: UIImageView!
    @IBOutlet private weak var tickerLabel: UILabel!
    @IBOutlet private weak var tickerInfoLabel: UILabel!
    @IBOutlet private weak var changeLabel: UILabel!
    @IBOutlet private weak var changeInfoLabel: UILabel!
    
    @IBOutlet private weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var containerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Variables
    
    private var appearance: Appearance = .normal {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Setup

private extension QuotesTableViewCell {
    func setupUI() {
        container.translatesAutoresizingMaskIntoConstraints = false
        containerLeadingConstraint.constant = Constants.horizontalPadding
        containerTrailingConstraint.constant = Constants.horizontalPadding
        containerTopConstraint.constant = Constants.verticalPadding
        containerBottomConstraint.constant = Constants.verticalPadding
        
        firstLine.spacing = Constants.spacing
        secondLine.spacing = Constants.spacing
        
        changeLabel.layer.masksToBounds = true
        changeLabel.layer.cornerRadius = .close
        
        stockImage.isHidden = true
    }
    
    func updateUI() {
        switch appearance {
        case .normal:
            changeLabel.backgroundColor = .clear
            changeLabel.textColor = getChangeLabelColor()
        case .positive:
            changeLabel.backgroundColor = UIColor.Main.positive
            changeLabel.textColor = UIColor.Main.background
        case .negative:
            changeLabel.backgroundColor = UIColor.Main.negative
            changeLabel.textColor = UIColor.Main.background
        }
    }
    
    func getChangeLabelColor() -> UIColor {
        guard let change = Double(changeLabel.text ?? .empty), change != 0 else {
            return UIColor.Main.text
        }
        if change > 0 {
            return UIColor.Main.positive
        } else {
            return UIColor.Main.negative
        }
    }
}

// MARK: - Public interface

extension QuotesTableViewCell {
    func configure(with model: QuotesInfo) {
        tickerLabel.text = model.ticker
        tickerInfoLabel.text = "\(model.exchangeName ?? Constants.placeholder) | \(model.stockName ?? Constants.placeholder)"
        changeLabel.text = model.procentChange != nil ? model.procentChange!.print("%.2f") : Constants.placeholder
        changeInfoLabel.text = "\(model.lastOrderPrice?.minStepFormat(model.minStep) ?? Constants.placeholder) (\(model.change?.minStepFormat(model.minStep) ?? Constants.placeholder))"
        
        stockImage?.kf.setImage(
            with: Services.quotes.getTickerImageUrl(for: model.ticker),
            placeholder: UIImage(named: "stockPlaceholder"),
            options: [
                .cacheOriginalImage
            ],
            progressBlock: nil,
            completionHandler: { result in
                switch result {
                case .success(let value):
                    if value.image.size.width <= 1 {
                        self.stockImage.isHidden = true
                    } else {
                        self.stockImage.isHidden = false
                    }
                case .failure( _):
                    self.stockImage.image = UIImage(named: "stockPlaceholder")
                }
                
            }
        )
        
        appearance = Appearance(model)
    }
    
    func setAppearance(_ appearance: Appearance) {
        self.appearance = appearance
    }
    
    var appearanceIsHighlighted: Bool {
        return appearance != .normal
    }
}

// MARK: - Enums

extension QuotesTableViewCell {
    enum Appearance: Int {
        case positive
        case negative
        case normal
        
        init(_ model: QuotesInfo) {
            guard let updateTime = model.updateTime, Date().timeIntervalSince(updateTime) < QuotesListViewController.Constants.highlitedTime else {
                self = .normal
                return
            }
            switch model.changedType {
            case .positive:
                self = .positive
            case .negative:
                self = .negative
            case .none:
                self = .normal
            }
        }
    }
}


// MARK: - Constants

private extension QuotesTableViewCell {
    struct Constants {
        static let horizontalPadding: CGFloat = .middle
        static let verticalPadding: CGFloat = .half
        static let spacing: CGFloat = .close
        static let placeholder: String = "-"
    }
}
