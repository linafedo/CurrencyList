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
    case serverError
    
    static func handleNetworkResponse(_ response: HTTPURLResponse) -> NetworkResponse {
        switch response.statusCode {
        case 200...299: return .success
        case 400...499: return .badRequest
        case 500...599: return .serverError
        default: return .failed
        }
    }
}
