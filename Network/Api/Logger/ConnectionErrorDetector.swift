import Foundation

public final class ConnectionErrorDetector {
    public init() {}
}

// MARK: - ConnectionErrorDetecting

extension ConnectionErrorDetector: ConnectionErrorDetecting {
    public func isConnectionError(_ error: Error) -> Bool {
        if let error = error as? ResponseError {
            switch error {
            case let .request(requestError):
                return isConnectionError(requestError)
            default: break
            }
        }

        let nsError = error as NSError

        let domain = nsError.domain

        if domain != NSURLErrorDomain {
            return false
        }

        let connectionErrorCodes = [NSURLErrorTimedOut, NSURLErrorCannotFindHost,
                                    NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost,
                                    NSURLErrorDNSLookupFailed, NSURLErrorResourceUnavailable,
                                    NSURLErrorNotConnectedToInternet, NSURLErrorInternationalRoamingOff,
                                    NSURLErrorCallIsActive, NSURLErrorDataNotAllowed,
                                    NSURLErrorSecureConnectionFailed]

        let errorCode = nsError.code

        return connectionErrorCodes.contains(errorCode)
    }
}
