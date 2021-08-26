import Foundation

public typealias BaseVerifyingDataTaskResult = Result<(Data, HTTPURLResponse), ResponseError>
public typealias BaseVerifyingDataTaskCompletion = (BaseVerifyingDataTaskResult) -> Void

public protocol BaseDataTasksBuilding {
    var session: URLSessionManaging { get }

    /// Creates new dataTask which checks
    /// HTTP-status and tries to decode answer
    ///
    /// - Parameters:
    ///   - request: Request itself
    ///   - isEmptyResponse: Falg to skip check for empty response
    ///   - completionHandler: Completion closure
    /// - Returns: DataTask object
    func baseVerifyingDataTask(
        request: URLRequest,
        completionHandler: @escaping BaseVerifyingDataTaskCompletion
    )
        -> DataTaskManaging
}
