import Foundation

public protocol APIDataTasksBuilding {
    func buildDataTask<Type: Decodable>(
        request: URLRequest,
        completion: @escaping (Result<Type, Error>) -> Void,
        function: String
    ) -> DataTaskManaging
}

public extension APIDataTasksBuilding {
    func buildDataTask<Type: Decodable>(
        request: URLRequest,
        completion: @escaping (Result<Type, Error>) -> Void,
        function: String = #function
    ) -> DataTaskManaging {
        return buildDataTask(
            request: request,
            completion: completion,
            function: function
        )
    }
}

// MARK: - Common

typealias EmptyTaskCompletion = (Result<EmptyResponse, Error>) -> Void
typealias LoadTodoCorrectTaskCompletion = (Result<CorrectResponse, Error>) -> Void
typealias LoadTodoWrongTaskCompletion = (Result<WrongResponse, Error>) -> Void
