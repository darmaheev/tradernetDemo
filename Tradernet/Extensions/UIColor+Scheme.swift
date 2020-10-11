import UIKit

// MARK: - Scheme

extension UIColor {
    struct Main {
        /// #FFF
        static let background = UIColor(named: "backgroundColor")!
        /// #444
        static let text       = UIColor(named: "textColor")!
        /// #72BF44
        static let positive   = UIColor(named: "positiveColor")!
        /// #FF2D55
        static let negative   = UIColor(named: "negativeColor")!
    }
}

// MARK: - HEX

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") { cString.removeFirst() }

        if (cString.count) != 6 {
            self.init(hex: "ffffff")
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
