import Foundation

public struct BaseDataTasksBuilder: BaseDataTasksBuilding {
    public let session: URLSessionManaging
    private let reachabilityChecker: ReachabilityChecking

    public init(session: URLSessionManaging,
                reachabilityChecker: ReachabilityChecking) {
        self.session = session
        self.reachabilityChecker = reachabilityChecker
    }

    public func baseVerifyingDataTask(
        request: URLRequest,
        completionHandler: @escaping BaseVerifyingDataTaskCompletion
    ) -> DataTaskManaging {
        // NOTE: It could be nil. It might mean that reachability has started, but status not changed yet
        guard reachabilityChecker.currentStatus() != .unavailable else {
            fatalError("No Connection!")
        }

        let dataTask = session.smDataTask(with: request) { responseData, response, responseError in
            // Request can exist without httmMethod, thanks to Apple
            let httpMethod = request.httpMethod

            if let responseError = responseError {
                let error = ResponseError.request(error: responseError)
                completionHandler(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let notHTTPError = ResponseError.notHTTPResponse(response: response)
                completionHandler(.failure(notHTTPError))
                return
            }

            guard let responseData = responseData else {
                completionHandler(.failure(ResponseError.emptyData))
                return
            }
            
            let httpStatusCode = httpResponse.statusCode

            if httpStatusCode != HTTPStatusCode.ok.rawValue {
                let statusCodeNotOkError =
                    ResponseError.httpStatusNotOk(
                        statusCode: httpStatusCode,
                        response: httpResponse,
                        data: String(data: responseData, encoding: .utf8),
                        httpMethod: httpMethod
                    )
                
                completionHandler(.failure(statusCodeNotOkError))
                return
            }

            completionHandler(.success((responseData, httpResponse)))
        }

        return dataTask
    }
}
