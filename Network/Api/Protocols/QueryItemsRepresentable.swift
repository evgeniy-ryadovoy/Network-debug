import Foundation

public protocol QueryItemsRepresentable {
    func queryItems() -> [URLQueryItem]
}
