import Foundation

class MulticastDelegate <T> {
    private var weakDelegates = [WeakWrapper]()

    static func += <T: AnyObject> (left: MulticastDelegate<T>, right: T) {
        left.addDelegate(right)
    }

    static func -= <T: AnyObject> (left: MulticastDelegate<T>, right: T) {
        left.removeDelegate(right)
    }

    func addDelegate(_ delegate: T) {
        weakDelegates.append(WeakWrapper(value: delegate as AnyObject))
    }

    func removeDelegate(_ delegate: T) {
        weakDelegates.removeAll(where: { $0.value === (delegate as AnyObject) })
    }

    func invoke(onMainThread: Bool = true, invocation: @escaping (T) -> Void) {
        let block = {
            for (index, delegate) in self.weakDelegates.enumerated().reversed() {
                if let delegate = delegate.value {
                    invocation(delegate as! T)
                } else {
                    self.weakDelegates.remove(at: index)
                }
            }
        }
        if onMainThread {
            performOnMainThread(block)
        } else {
            block()
        }
    }
}

private class WeakWrapper {
    weak var value: AnyObject?

    init(value: AnyObject) {
        self.value = value
    }
}
