import Foundation

public protocol URLSessionManaging {
    func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Swift.Void)

    func smDataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void
    ) -> DataTaskManaging
}
