import Foundation

public final class APIDataTasksBuilder {
    private let baseDataTasksBuilder: BaseDataTasksBuilding
    private let decoder: JSONDecoder

    // MARK: Init

    public init(
        baseDataTasksBuilder: BaseDataTasksBuilding,
        decoder: JSONDecoder
    ) {
        self.baseDataTasksBuilder = baseDataTasksBuilder
        self.decoder = decoder
    }

    // MARK: Private

    private func createGenericBaseVerifyingDataTask<Type: Decodable>(
        request: URLRequest,
        completion: @escaping (Result<Type, Error>) -> Void,
        function: String = #function
    )
        -> DataTaskManaging {
        let isEmptyResponseAllowed = (Type.self == EmptyResponse.self)

        let dataTask = baseDataTasksBuilder.baseVerifyingDataTask(request: request) { [weak self] baseTaskResult in

            guard let strongSelf = self else {
                return
            }

            var debugError: ResponseError?

            switch baseTaskResult {
            case let .failure(error):
                
                switch error {
                case .emptyData:
                    // For some requests we have only http code
                    if isEmptyResponseAllowed {
                        completion(.success(EmptyResponse() as! Type))
                        return
                    }

                case let .httpStatusNotOk(_, _, data, _):
                    //  Try parse some base error
                    //  let baseError =
                    //     try strongSelf.decoder.decode(BaseError.self,
                    //                                   from: data)
                    break
                    
                default:
                    break
                }

                debugError = error
                completion(.failure(error))

            case let .success(responseData, httpResponse):

                do {
                    let responseObject = try strongSelf.decoder.decode(
                        Type.self,
                        from: responseData
                    )
                    completion(.success(responseObject))
                } catch {
                    debugError = ResponseError.mapping(
                        error: error,
                        data: String(data: responseData, encoding: .utf8) ?? ""
                    )

                    completion(.failure(debugError!))
                }
            }

            if let error = debugError {
                // Remote logger
                // strongSelf.responseErrorsLogger.log(error, method: function)
            }
        }

        return dataTask
    }
}

extension APIDataTasksBuilder: APIDataTasksBuilding {
    public func buildDataTask<Type: Decodable>(
        request: URLRequest,
        completion: @escaping (Result<Type, Error>) -> Void,
        function: String
    ) -> DataTaskManaging {
        return createGenericBaseVerifyingDataTask(
            request: request,
            completion: completion,
            function: function
        )
    }
}
