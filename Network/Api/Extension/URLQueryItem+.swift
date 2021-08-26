import Foundation

extension URLQueryItem {
    init(attribute: CustomStringConvertible, value: CustomStringConvertible) {
        let realName = String(describing: attribute)
        let realValue = String(describing: value)

        self.init(name: realName, value: realValue)
    }
}
