import Foundation

public enum ParseError: Error {
    case unsupportedField(objectType: String, fieldName: String)
}
