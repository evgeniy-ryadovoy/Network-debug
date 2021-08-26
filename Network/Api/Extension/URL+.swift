import Foundation

public extension URL {
    func appendQueryItems(_ queryItems: [URLQueryItem]) throws -> URL {
        if queryItems.isEmpty {
            return self
        }

        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw URLError.cannotBeFormed
        }

        var newQueryItemsList = components.queryItems

        if newQueryItemsList == nil {
            newQueryItemsList = [URLQueryItem]()
        }

        newQueryItemsList?.append(contentsOf: queryItems)

        components.queryItems = newQueryItemsList

        guard let appendedURL = components.url else {
            throw URLError.cannotBeFormed
        }

        return appendedURL
    }

    func appendedURL(queryItems appendQueryItems: [URLQueryItem]) throws -> URL {
        if appendQueryItems.isEmpty {
            return self
        }

        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw URLError.cannotBeFormed
        }

        var newQueryItemsList = components.queryItems

        if newQueryItemsList == nil {
            newQueryItemsList = [URLQueryItem]()
        }

        newQueryItemsList?.append(contentsOf: appendQueryItems)

        components.queryItems = newQueryItemsList

        guard let appendedURL = components.url else {
            throw URLError.cannotBeFormed
        }

        return appendedURL
    }
}

public extension URL {
    init?(_ string: String) {
        if URL(string: string) != nil {
            self.init(string: string)
            return
        }

        if let path = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           URL(string: path) != nil {
            self.init(string: path)
            return
        }
        
        return nil
    }
    
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
}

