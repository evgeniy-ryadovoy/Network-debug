import Foundation

struct CorrectResponse: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
