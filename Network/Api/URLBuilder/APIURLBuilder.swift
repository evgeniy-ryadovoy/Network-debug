import Foundation

public struct APIURLBuilder {
    private let baseURL: String
    private let apiVersion: String
    private let apiVersionPrefix: String

    // MARK: Init

    public init(
        baseURL: String,
        apiVersion: String,
        apiVersionPrefix: String
    ) {
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.apiVersionPrefix = apiVersionPrefix
    }
}

// MARK: - URLBuilding

extension APIURLBuilder: URLBuilding {
    public func buildURL(methodPath: MethodPath) throws -> URL {
        var version = apiVersionPrefix + apiVersion
        if !version.isEmpty {
            version = "/" + version
        }

        var path = methodPath.path
        if !path.hasPrefix("/") {
            path = "/" + path
        }

        let urlString = baseURL + version + path

        guard let methodURL = URL(urlString) else {
            throw URLError.cannotBeFormed
        }

        return methodURL
    }
}
