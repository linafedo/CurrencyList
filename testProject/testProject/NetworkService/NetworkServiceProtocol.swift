//
//  NetworkServiceProtocol.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation

typealias NetworkRouterCompletion = (_ data: Data?, _ response: NetworkResponse?, _ error: Error?) -> ()
typealias Parameters = [String: Any]

protocol NetworkServiceProtocol {
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
}
