import UIKit

// MARK: - String extensions

extension String {
    static let empty = ""
    static let dot = "."
    static let space = " "

    var isNotEmpty: Bool {
        return !isEmpty
    }
}

// MARK: - Double extensions

extension Double {
    func print(_ format: String = "%g") -> String {
        return (self > 0 ? "+" : .empty) + String(format: format, self)        
    }
    
    func minStepFormat(_ minStep: Double?) -> String {
        guard let minStep = minStep else {
            return String(format: "%g", self)
        }
        let def = 10000000000.0
        var roundedMinStep = (minStep * def).rounded()/def
        var delta = 0
        while roundedMinStep != 0 {
            roundedMinStep = (roundedMinStep * 10).truncatingRemainder(dividingBy: 1)
            delta += 1
        }
        return String(format: "%.\(delta)f", self)
    }
}

// MARK: - CGFloat extensions

extension CGFloat {
/// 4
    static let close = CGFloat(4)
/// 8
    static let half = CGFloat(8)
/// 12
    static let small = CGFloat(12)
/// 16
    static let middle = CGFloat(16)
/// 24
    static let big = CGFloat(24)
/// 32
    static let double = CGFloat(32)
/// 48
    static let huge = CGFloat(48)
}

// MARK: - Typealias

typealias ResultBlock<T> = () -> T
typealias EmptyBlock = ResultBlock<Void>

// MARK: - Thread functions

func performOnMainThread(and wait: Bool = true, _ block: @escaping EmptyBlock) {
    if Thread.isMainThread {
        block()
    } else if wait {
        DispatchQueue.main.sync(execute: block)
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

// MARK: - Localize functions

func localize(_ text: String?) -> String {
    return NSLocalizedString(text ?? .empty, comment: .empty)
}
