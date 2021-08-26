import Foundation

private enum TokenNeccessity {
    case mandatory
    case optional
    case notNeeded
}

public struct APIURLRequestsFactory {
    let defaultCachePolicy: URLRequest.CachePolicy

    // MARK: Init

    public init(
        cachePolicy: URLRequest.CachePolicy
    ) {
        defaultCachePolicy = cachePolicy
    }

    // MARK: Basic Bulder Methods

    /**
     Create simple URL query. Params added to url string
     */
    private func buildURLRequest(
        url: URL,
        query: QueryItemsRepresentable?,
        method: HTTPMethod,
        timeoutInterval: TimeInterval = Constants.defaultRequestTimeout,
        cachePolicy: URLRequest.CachePolicy? = nil,
        tokenNeccessity: TokenNeccessity = .mandatory
    ) throws -> URLRequest {
        var queredURL = url

        if let query = query {
            queredURL = try url.appendedURL(queryItems: query.queryItems())
        }

        let requestCachePolicy = cachePolicy ?? defaultCachePolicy
        var request = URLRequest(
            url: queredURL,
            cachePolicy: requestCachePolicy,
            timeoutInterval: timeoutInterval
        )
        request.httpMethod = method.rawValue

        try addCommonHeaders(&request, tokenNeccessity: tokenNeccessity)

        return request
    }

    /**
     Create URL query. Params added to body
     */
    private func buildBodyParamsRequest(
        url: URL,
        query: QueryItemsRepresentable?,
        method: HTTPMethod = .post,
        timeoutInterval: TimeInterval = Constants.defaultRequestTimeout,
        cachePolicy: URLRequest.CachePolicy? = nil,
        tokenNeccessity: TokenNeccessity = .mandatory,
        isNeedPercentEncoding: Bool = true
    ) throws -> URLRequest {
        var queryString: String?

        if let query = query {
            var urlComponents = URLComponents()
            urlComponents.queryItems = query.queryItems()
            if isNeedPercentEncoding {
                queryString = urlComponents.percentEncodedQuery
            } else {
                queryString = urlComponents.query
            }
        } else {
            queryString = nil
        }

        let requestCachePolicy = cachePolicy ?? defaultCachePolicy
        var request = URLRequest(
            url: url,
            cachePolicy: requestCachePolicy,
            timeoutInterval: timeoutInterval
        )
        request.httpMethod = method.rawValue
        request.httpBody = queryString?.data(using: .utf8)

        try addCommonHeaders(&request, tokenNeccessity: tokenNeccessity)

        return request
    }

    /**
     Create URL query. JSON params added to body
     */
    private func buildJSONParamsRequest(
        url: URL,
        model: JSONRepresentable,
        method: HTTPMethod = .post,
        timeoutInterval: TimeInterval = Constants.defaultRequestTimeout,
        cachePolicy: URLRequest.CachePolicy? = nil,
        tokenNeccessity: TokenNeccessity = .mandatory
    ) throws -> URLRequest {
        let requestCachePolicy = cachePolicy ?? defaultCachePolicy
        var request = URLRequest(
            url: url,
            cachePolicy: requestCachePolicy,
            timeoutInterval: timeoutInterval
        )
        request.httpMethod = method.rawValue
        request.httpBody = model.toData()

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        try addCommonHeaders(&request, tokenNeccessity: tokenNeccessity)

        return request
    }

    // MARK: Helpers

    private func addAdditionalHeaders(_ request: inout URLRequest, additionalHeaders: [String: String]) {
        additionalHeaders.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
    }

    private func addCommonHeaders(
        _ request: inout URLRequest,
        tokenNeccessity: TokenNeccessity = .mandatory,
        function: String = #function
    ) throws {
        switch tokenNeccessity {
        case .mandatory:
            let token = "Some token"
            let authorization = "Token token=\(token)"
            request.setValue(authorization, forHTTPHeaderField: HTTPHeader.authorization.rawValue)

        case .optional:
            /*if let token = try? tokenSource.readPassword(), !token.isEmpty {
                let authorization = "Token token=\(token)"
                request.setValue(authorization, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            }*/
            break
        
        case .notNeeded:
            break
        }

        request.setValue(Constants.clientId, forHTTPHeaderField: HTTPHeader.clientId.rawValue)
    }

    private func buildImageBody(
        parameters: [String: Any],
        boundary: String,
        data: Data,
        mimeType: String,
        filename: String
    ) -> Data {
        var body = Data()

        for (key, value) in parameters {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }

        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8))
        body.append(data)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))

        return body
    }
}

// MARK: - ConfigurationRequestFactoring

extension APIURLRequestsFactory: TodosRequestFactoring {
    public func loadTodos(url: URL) throws -> URLRequest {
        return try buildURLRequest(url: url,
                                   query: nil,
                                   method: .get,
                                   tokenNeccessity: .notNeeded)
    }
    
    public func createTodos(url: URL,
                            jsonModel: CreateToDoRequestModel)
    throws -> URLRequest {
        return try buildJSONParamsRequest(url: url,
                                          model: jsonModel,
                                          method: .put,
                                          tokenNeccessity: .notNeeded)
    }
}
