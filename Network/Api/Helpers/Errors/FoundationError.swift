import Foundation

public enum FoundationError: Error {
    case decimalFromDoubleMapping(Double)

    var localizedDescription: String {
        switch self {
        case let .decimalFromDoubleMapping(double):
            return "Can not cast Double to Decimal from \(double)"
        }
    }
}
