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
                
        let key = url.absoluteString.replacingOccurrences(of: "/", with: "")
        if let image = self.checkCache(key: key) {
            completion?(image)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in            
            if let data = data, let image = UIImage(data: data) {
                
                self.cache.insertValue(data, forKey: key)
                completion?(image)
            }
        }.resume()
    }
}
