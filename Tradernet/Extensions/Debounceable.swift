import Foundation

protocol Debounceable {
    func debounce(delay: TimeInterval, action: @escaping () -> Void) -> () -> Void
}

extension Debounceable {
    func debounce(delay: TimeInterval, action: @escaping () -> Void) -> () -> Void {
        let callback = Callback(action)
        var timer: Timer?
        return {
            if let timer = timer {
                timer.invalidate()
            }
            timer = Timer(timeInterval: delay, target: callback, selector: #selector(Callback.go), userInfo: nil, repeats: false)
            guard let timer = timer else { return }
            RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        }
    }
}

private class Callback {
    let handler: () -> Void

    init(_ handler: @escaping () -> Void) {
        self.handler = handler
    }

    @objc func go() {
        handler()
    }
}
