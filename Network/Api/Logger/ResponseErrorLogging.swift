import Foundation

public protocol ResponseErrorLogging {
    func log(_ error: ResponseError, method: String)
}
