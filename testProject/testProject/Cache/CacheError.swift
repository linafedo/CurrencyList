//
//  CacheError.swift
//  testProject
//
//  Created by Galina Fedorova on 21.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation

extension Cache {
    enum Error: String {
        case save
        case read
        case delete
        case invalidName
        
        var description: String {
            switch self {
            case .save:
                return "CACH: Error saving file to disk"
            case .read:
                return "CACH: Error reading file from disk"
            case .delete:
                return "CACH: Error deleting file from disk"
            case .invalidName:
                return "invalid file name"
            }
        }
    }
    
    enum Success: String {
        case readFromCache
        case readFromDisk
        case saveToDisk
        
        var description: String {
            switch self {
            case .readFromCache:
                return "CACH: file found in cache"
            case .readFromDisk:
                return "CACH: file found in disk"
            case .saveToDisk:
                return  "CACH: file saved to disk"
            }
        }
    }
}
