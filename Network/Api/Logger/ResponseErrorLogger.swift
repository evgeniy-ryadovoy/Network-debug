import Foundation

final class ResponseErrorEmptyData: NSError {}
final class ResponseErrorMapping: NSError {}
final class ResponseErrorNotHTTPResponse: NSError {}
final class ResponseErrorHTTPStatusNotOk: NSError {}
final class ResponseBaseError: NSError {}
final class ResponseErrorHTTPNotAuthorized: NSError {}
final class ResponseErrorRequest: NSError {}

public final class ResponseErrorLogger {
    private enum LocalConstants {
        static let defaultStatusCode = 200
        static let unkownURLPathTemplate = "Unknown"
    }

    let remoteErrorsLogger: RemoteErrorLogging
    let connectionErrorDetector: ConnectionErrorDetecting

    public init(
        remoteErrorsLogger: RemoteErrorLogging,
        connectionErrorDetector: ConnectionErrorDetecting
    ) {
        self.remoteErrorsLogger = remoteErrorsLogger
        self.connectionErrorDetector = connectionErrorDetector
    }

    // MARK: Private

    private func urlDescription(for url: URL?) -> String {
        return url?.absoluteString ?? LocalConstants.unkownURLPathTemplate
    }

    private func fingerprintGroup(with params: [String]) -> [String] {
        return ["{{ default }}"] + params
    }
}

// MARK: - ResponseErrorLogging

extension ResponseErrorLogger: ResponseErrorLogging {
    public func log(_ responseError: ResponseError, method: String) {
        let errorDescription = String(describing: responseError)
        var additionalErrorInfo: [String: Any] = [ResponseErrorInfoKey.apiMethod: method,
                                                  ResponseErrorInfoKey.errorDescription: errorDescription]

        switch responseError {
        case .emptyData:
            let domain = String(describing: type(of: ResponseErrorEmptyData.self))
            additionalErrorInfo[ResponseErrorInfoKey.fingerprint] = fingerprintGroup(with: [method])

            let errorForReport = ResponseErrorEmptyData(
                domain: domain,
                code: LocalConstants.defaultStatusCode,
                userInfo: additionalErrorInfo
            )
            remoteErrorsLogger.capture(error: errorForReport)

        case let .httpStatusNotOk(statusCode, response, stringData, httpMethod):
            let path = urlDescription(for: response.url)
            var specificAdditionalErrorInfo: [String: Any] = [ResponseErrorInfoKey.apiMethod: method]
            specificAdditionalErrorInfo[ResponseErrorInfoKey.requestURLPath] = path
            specificAdditionalErrorInfo[ResponseErrorInfoKey.fingerprint] = fingerprintGroup(with: [method, String(statusCode)])
            specificAdditionalErrorInfo[ResponseErrorInfoKey.responseObjectUserInfoKey] = stringData
            
            let domain = String(describing: type(of: ResponseBaseError.self))
            let crashlyticsError = ResponseErrorHTTPStatusNotOk(
                domain: domain,
                code: statusCode,
                userInfo: specificAdditionalErrorInfo
            )
            remoteErrorsLogger.capture(error: crashlyticsError)

        case let .mapping(response, error, data):
            let path = urlDescription(for: response.url)
            var specificAdditionalErrorInfo: [String: Any] = [ResponseErrorInfoKey.apiMethod: method]
            specificAdditionalErrorInfo[ResponseErrorInfoKey.requestURLPath] = path
            specificAdditionalErrorInfo[ResponseErrorInfoKey.responseObjectUserInfoKey] = data
            specificAdditionalErrorInfo[ResponseErrorInfoKey.responseDecoderUserInfoKey] = error.localizedDescription
            specificAdditionalErrorInfo[ResponseErrorInfoKey.responseDecoderReasonKey] = String(describing: error)
            specificAdditionalErrorInfo[ResponseErrorInfoKey.fingerprint] = fingerprintGroup(with: [method])

            let domain = String(describing: type(of: ResponseErrorMapping.self))
            let errorForReport = ResponseErrorMapping(
                domain: domain,
                code: response.statusCode,
                userInfo: specificAdditionalErrorInfo
            )

            remoteErrorsLogger.capture(error: errorForReport)

        case let .notHTTPResponse(response):
            var specificAdditionalErrorInfo = additionalErrorInfo
            specificAdditionalErrorInfo[ResponseErrorInfoKey.responseObjectUserInfoKey] = response.debugDescription

            let domain = String(describing: type(of: ResponseErrorNotHTTPResponse.self))
            let errorForReport = ResponseErrorNotHTTPResponse(
                domain: domain,
                code: LocalConstants.defaultStatusCode,
                userInfo: specificAdditionalErrorInfo
            )

            remoteErrorsLogger.capture(error: errorForReport)

        case .notAuthorized:
            break
            
        case let .request(requestError):
            let nsError = requestError as NSError

            // Won't log errors if no connection -
            if !connectionErrorDetector.isConnectionError(requestError) {
                let isCanceledError = (nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled)
                if !isCanceledError {
                    var specificAdditionalErrorInfo = additionalErrorInfo
                    specificAdditionalErrorInfo[ResponseErrorInfoKey.responseObjectUserInfoKey] = requestError.localizedDescription
                    specificAdditionalErrorInfo[ResponseErrorInfoKey.fingerprint] = fingerprintGroup(with: [method, String(nsError.code)])

                    let domain = String(describing: type(of: ResponseErrorRequest.self))
                    let errorForReport = ResponseErrorRequest(
                        domain: domain,
                        code: nsError.code,
                        userInfo: specificAdditionalErrorInfo
                    )

                    remoteErrorsLogger.capture(error: errorForReport)
                }
            }
        }
    }
}
