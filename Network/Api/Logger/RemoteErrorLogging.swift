import Foundation

public protocol RemoteErrorLogging {
    func capture(error: Error)
}
