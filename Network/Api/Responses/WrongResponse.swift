import Foundation

struct WrongResponse: Codable {
    let superUserId: Int
    let id: Int
    let title: String
    let completed: Bool
}
