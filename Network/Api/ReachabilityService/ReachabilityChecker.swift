import Foundation

public class MulticastDelegate<T> {
    private let delegates: NSHashTable<AnyObject>

    /// delegates needs for tests.
    public init(delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()) {
        self.delegates = delegates
    }

    public func add(_ delegate: T) {
        delegates.add(delegate as AnyObject)
    }

    public func remove(_ delegateToRemove: T) {
        for delegate in delegates.allObjects.reversed() {
            if delegate === delegateToRemove as AnyObject {
                delegates.remove(delegate)
            }
        }
    }

    public func invoke(_ invocation: (T) -> Void) {
        for delegate in delegates.allObjects.reversed() {
            guard let delegateTyped = delegate as? T else {
                return
            }
            invocation(delegateTyped)
        }
    }
}

public final class ReachabilityChecker {
    private var reachability: Reachability?
    private let reachabilityStrategy: ReachabilityStrategy

    private var isNotifierRunning: Bool {
        return reachability?.notifierRunning ?? false
    }

    private var listeners = MulticastDelegate<ReachabilityListener>()

    private var status: ReachabilityStatus?

    public init(hostname: String?, reachabilityStrategy: ReachabilityStrategy) {
        if let hostname = hostname {
            reachability = try? Reachability(hostname: hostname)
        } else {
            reachability = try? Reachability()
        }

        self.reachabilityStrategy = reachabilityStrategy
        assert(reachability != nil, "Reachability couldn't be created.")
    }
}

// MARK: - ReachabilityChecking

extension ReachabilityChecker: ReachabilityChecking {
    public func start() throws {
        listenChanges()

        if !isNotifierRunning {
            try reachability?.startNotifier()
        }
    }

    public func stop() {
        if isNotifierRunning {
            reachability?.stopNotifier()
        }
    }

    public func addListener(_ listener: ReachabilityListener) {
        listeners.add(listener)
    }

    public func removeListener(_ listener: ReachabilityListener) {
        listeners.remove(listener)
    }

    public func currentStatus() -> ReachabilityStatus? {
        return status
    }

    // MARK: Private

    private func listenChanges() {
        let changeBlock: (Reachability) -> Void = { [weak self] reachability in
            self?.changeStatus(reachability: reachability)
        }

        reachability?.whenReachable = changeBlock
        reachability?.whenUnreachable = changeBlock
    }

    private func changeStatus(reachability: Reachability) {
        let status = resolveStrategy(reachability: reachability)
        self.status = status
        notifyAll(status: status)
    }

    private func notifyAll(status: ReachabilityStatus) {
        listeners.invoke { listener in
            listener.changeReachabilityStatus(status)
        }
    }

    private func resolveStrategy(reachability: Reachability) -> ReachabilityStatus {
        switch reachabilityStrategy {
        case .wifiOnly:
            return reachability.connection == .wifi ? .available : .unavailable
        case .wifiOrCellular:
            return reachability.connection == .wifi ||
                reachability.connection == .cellular ? .available : .unavailable
        }
    }
}
