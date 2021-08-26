import Foundation

// sourcery: AutoMockable
public protocol DataTaskManaging: AnyObject {
    func resume()
    func cancel()
}
