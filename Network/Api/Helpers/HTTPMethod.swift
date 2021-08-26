import Foundation

public enum HTTPMethod: String, CustomStringConvertible {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"

    public var description: String {
        return rawValue
    }
}
