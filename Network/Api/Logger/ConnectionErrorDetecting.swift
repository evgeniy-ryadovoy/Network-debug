public protocol ConnectionErrorDetecting {
    func isConnectionError(_ error: Error) -> Bool
}
