import Foundation

public enum ResponseError: Error {
    case request(error: Error)
    case notHTTPResponse(response: URLResponse?)
    case httpStatusNotOk(statusCode: Int,
                         response: HTTPURLResponse,
                         data: String?,
                         httpMethod: String?)
    case emptyData
    case mapping(error: Error, data: String)
    case notAuthorized
}
