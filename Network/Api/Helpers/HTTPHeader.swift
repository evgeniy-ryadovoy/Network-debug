import Foundation

public enum HTTPHeader: String {
    case authorization = "Authorization"
    case userAgent = "User-Agent"
    case clientId = "Client-Id"
    case clientVer = "Client-Ver"
    case clientToken = "Client-Token"
    case apiVersion = "Api-Version"

    public var description: String {
        return rawValue
    }
}
