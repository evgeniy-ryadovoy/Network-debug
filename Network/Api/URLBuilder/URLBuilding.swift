import Foundation

public protocol URLBuilding {
    func buildURL(methodPath: MethodPath) throws -> URL
}
