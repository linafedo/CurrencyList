//
//  NetworkService.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    
    private init() { }
    
    private var task: URLSessionTask?
    
    static let shared: NetworkServiceProtocol = NetworkService()
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
                
        do {
            let request = try self.buildRequest(from: route)
            
            task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if let response = response as? HTTPURLResponse {
//                    NetworkService.logResponse(response, error: error, httmMethod: route.httpMethod)
                }
                
                if let data = data, let response = response as? HTTPURLResponse {
                    
                    let result = NetworkResponse.handleNetworkResponse(response)
                    completion(data, result, nil)
                    
                } else {
                    completion(data, nil, error)
                }
            })
            
        } catch {
            completion(nil, nil, error)
        }
        
        self.task?.resume()
    }
    
    func cancelTask() {
        print(" таска отменена ")
        self.task?.cancel()
    }
        
}

// MARK: - Utility

extension NetworkService {
    
    private func buildRequest(from route: EndPoint) throws -> URLRequest {
        
        guard let baseUrl = URL(string: Utility.baseRequestUrl) else {
            throw NetworkError.missingUrl
        }
        
        var request = URLRequest(url: baseUrl.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = route.httpMethod.rawValue
        
        if !route.parameters.isEmpty {
            do {
                try URLParameterEncoder.encode(urlRequest: &request, with: route.parameters)
            } catch {
                throw error
            }
        }
        
        return request
    }
    
}

private extension NetworkService {
    
    static func logResponse(_ response: HTTPURLResponse, error: Error?, httmMethod: HTTPMethod) {
        let method = httmMethod.rawValue
        let statusCode = response.statusCode
        let responseStatus = NetworkResponse.handleNetworkResponse(response)
        let url = response.url?.absoluteString ?? "UNKNOWN"
        let xTime = response.allHeaderFields["x-processing-time"] ?? "missing"
        let traceId = response.allHeaderFields["uber-trace-id"] ?? "missing"
        
        let errorText = error?.localizedDescription ?? ""
        
        print(
            "Network ->\n\(method) (\(responseStatus.rawValue))\n" +
                "URL: \(url)\n" +
                "STATUS CODE: \(String(describing: statusCode))\n" +
                "\(errorText.isEmpty ? "" : "Error: \(errorText)\n")" +
                "X-TIME: \(xTime)\n" +
            "Trace ID: \(traceId)\n"
        )
    }
    
}
