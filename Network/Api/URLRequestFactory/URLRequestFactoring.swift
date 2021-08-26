import Foundation

public protocol TodosRequestFactoring {
    func loadTodos(url: URL) throws -> URLRequest
}
