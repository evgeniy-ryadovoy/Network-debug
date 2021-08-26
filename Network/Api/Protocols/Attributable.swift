import Foundation

public protocol Attributable: CustomStringConvertible, Hashable {}

extension Attributable where Self: RawRepresentable, Self.RawValue == String {
    var description: String {
        return rawValue
    }
}
