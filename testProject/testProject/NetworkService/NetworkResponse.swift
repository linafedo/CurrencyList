//
//  NetworkResponse.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation

enum NetworkResponse {
    case success
    case badRequest
    case failed
    case authenticationError
    
    static func handleNetworkResponse(_ response: HTTPURLResponse) -> NetworkResponse {
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .authenticationError
        case 501...599: return .badRequest
        default: return .failed
        }
    }
}
