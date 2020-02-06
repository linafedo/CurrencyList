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
        
        self.task?.cancel()
        
        do {
            let request = try self.buildRequest(from: route)
            
            task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
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
    
}

// MARK: - Utility

extension NetworkService {
    
    private func buildRequest(from route: EndPoint) throws -> URLRequest {

        var request = URLRequest(url: route.baseUrl.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = route.httpMethod.rawValue
        
        if !route.headers.isEmpty {
            for (key, value) in route.headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
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
