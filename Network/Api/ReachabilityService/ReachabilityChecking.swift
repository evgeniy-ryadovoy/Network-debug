public enum ReachabilityStrategy {
    case wifiOnly
    case wifiOrCellular
}

public enum ReachabilityStatus {
    case available
    case unavailable
}

public protocol ReachabilityChecking {
    func start() throws
    func stop()

    func addListener(_ listener: ReachabilityListener)
    func removeListener(_ listener: ReachabilityListener)

    func currentStatus() -> ReachabilityStatus?
}
