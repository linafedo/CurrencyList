//
//  ImageLoader.swift
//  testProject
//
//  Created by Galina Fedorova on 14.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import UIKit

class ImageLoader {
    
    private static var cache = Cache<String, Data>()
    
    private static func checkCache(key: String) -> UIImage? {
        
        if let data = self.cache.getValue(forKey: key),
            let image = UIImage(data: data) {
            return image
        }
        
        return nil
    }
    
    static func loadImage(url: URL, completion: ((UIImage?) -> Void)?) {
                
        var key = url.absoluteString.replacingOccurrences(of: "/", with: "")
        
        if let image = self.checkCache(key: key) {
            completion?(image)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.logResponse(response as! HTTPURLResponse, error: error, httmMethod: .get)
            
            if let data = data, let image = UIImage(data: data) {
                
                var key = url.absoluteString.replacingOccurrences(of: "/", with: "")
                self.cache.insertValue(data, forKey: key)
                completion?(image)
            }
        }.resume()
        
    }
    
    static func logResponse(_ response: HTTPURLResponse, error: Error?, httmMethod: HTTPMethod) {
        let method = httmMethod.rawValue
        let statusCode = response.statusCode
        let responseStatus = NetworkResponse.handleNetworkResponse(response)
        let url = response.url?.absoluteString ?? "UNKNOWN"
        let xTime = response.allHeaderFields["x-processing-time"] ?? "missing"
        let traceId = response.allHeaderFields["uber-trace-id"] ?? "missing"
        
        let errorText = error?.localizedDescription ?? ""
        
        print(
            "IMAGE LOAD ->\n\(method) (\(responseStatus.rawValue))\n" +
                "URL: \(url)\n" +
                "STATUS CODE: \(String(describing: statusCode))\n" +
                "\(errorText.isEmpty ? "" : "Error: \(errorText)\n")" +
                "X-TIME: \(xTime)\n" +
            "Trace ID: \(traceId)\n"
        )
    }
}
