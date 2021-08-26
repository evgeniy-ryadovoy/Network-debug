import Foundation

public protocol JSONRepresentable: Codable {
    func toData() -> Data?
}

public extension JSONRepresentable {
    func toData() -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(self)
    }
}
