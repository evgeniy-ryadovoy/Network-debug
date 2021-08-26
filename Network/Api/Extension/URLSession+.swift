import Foundation

extension URLSessionDataTask: DataTaskManaging {}

extension URLSession: URLSessionManaging {
    public func smDataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> DataTaskManaging {
        let task = dataTask(with: request, completionHandler: completionHandler)
        return task
    }
}
