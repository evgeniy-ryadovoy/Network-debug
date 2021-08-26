//
//  ViewController.swift
//  Network
//
//  Created by Evgeniy on 22.08.2021.
//

import UIKit

class ViewController: UIViewController {

    private  let urlRequestFactory = APIURLRequestsFactory(cachePolicy: .reloadIgnoringCacheData)
    private let urlBuilder = APIURLBuilder(baseURL: "https://jsonplaceholder.typicode.com",
                                           apiVersion: "",
                                           apiVersionPrefix: "")
    
    static let reachabilityChecker: ReachabilityChecking = {
        #if targetEnvironment(simulator)
            return ReachabilityChecker(hostname: nil, reachabilityStrategy: .wifiOnly)
        #else
            return ReachabilityChecker(hostname: nil, reachabilityStrategy: .wifiOrCellular)
        #endif
    }()
    
    private var dataTaskBuilder: APIDataTasksBuilder?
    
    @IBAction func sendRequest() {
        let request: URLRequest
        let startDate = Date()
        
        do {
            let methodPath = MethodPath.todos(identifier: 1)
            let url = try urlBuilder.buildURL(methodPath: methodPath)
            request = try urlRequestFactory.loadTodos(url: url)
        } catch {
            debugPrint(error)
            return
        }
        
        let completion: LoadTodoCorrectTaskCompletion = { response in
            debugPrint("Execution: \(Date().timeIntervalSince(startDate))")
            
            switch response {
            case let .success(responseObject):
                debugPrint(responseObject)
            case let .failure(error):
                debugPrint(error)
            }
        }
        
        let dataTask = dataTaskBuilder?.buildDataTask(request: request,
                                                      completion: completion)
        dataTask?.resume()
    }
    
    @IBAction func sendWrongRequest() {
        let request: URLRequest

        do {
            let methodPath = MethodPath.todos(identifier: 1)
            let url = try urlBuilder.buildURL(methodPath: methodPath)
            request = try urlRequestFactory.loadTodos(url: url)
        } catch {
            debugPrint(error)
            return
        }
        
        let completion: LoadTodoWrongTaskCompletion = { response in
            
            switch response {
            case .success:
                debugPrint("YOPEE")
            case let .failure(error):
                debugPrint(error)
            }
        }
        
        let dataTask = dataTaskBuilder?.buildDataTask(request: request,
                                                      completion: completion)
        dataTask?.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        do {
            try ViewController.reachabilityChecker.start()
        } catch {}
        
        dataTaskBuilder = buildDataTaskBuilder()
    }

    private func buildDataTaskBuilder() -> APIDataTasksBuilder {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpCookieAcceptPolicy = .never
        sessionConfiguration.httpCookieStorage = nil
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        sessionConfiguration.urlCache = nil
        let urlSession = URLSession(configuration: sessionConfiguration)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dataTaskBuilder = BaseDataTasksBuilder(
            session: urlSession,
            reachabilityChecker: ViewController.reachabilityChecker
        )
        
        return APIDataTasksBuilder(
            baseDataTasksBuilder: dataTaskBuilder,
            decoder: decoder
        )
    }
}
