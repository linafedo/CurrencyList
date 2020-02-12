//
//  RepositoryProtocol.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation

protocol RepositoryProtocol {
    
    func fetchRemotesRates(completion: (() -> Void)?)
    func getLocalRates(completion: (([RateItem]) -> Void)?)
}
