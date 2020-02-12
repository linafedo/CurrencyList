//
//  RatesRepository.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation

class RatesRepository: RepositoryProtocol {

    private let networkService: NetworkServiceProtocol = NetworkService.shared
    
    func fetchRemotesRates(completion: (() -> Void)?) {
        var params: Parameters = [:]
        params["base"] = "EUR"
        
        let route = EndPoint(path: "/latest",
                             httpMethod: .get,
                             parameters: params)
        
        self.networkService.request(route) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            if let data = data {
                
                let items = self.map(data: data)
                items.forEach({ RateDataBase.putItem(item: $0) })
                
                completion?()
                
            } else {
                // TODO
            }
        }
    }
    
    func getLocalRates(completion: (([RateItem]) -> Void)?) {
        RateDataBase.getItems(
            onSuccess: { (items) in
                
                var rateItems = [RateItem]()
                
                for item in items {
                    let rateItem = RateItem(currency: item.currency,
                                            countryName: item.countryName,
                                            rate: item.rate)
                    rateItems.append(rateItem)
                }
                
                DispatchQueue.main.async {
                    completion?(rateItems)
                }
        },
            onFail: {
            // TODO
        })
    }
    
}

// MARK: - Mapper

extension RatesRepository {
    
    private func map(data: Data) -> [RateDBModel] {
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []),
            let json = jsonResponse as? [String: Any],
            let rates = json["rates"] as? [String: Double] {
            
            var items = [RateDBModel]()
            
            for (key, value) in rates {
                
                let item = RateDBModel()
                item.currency = key
                item.rate = round(1000 * value) / 1000
                
                if !RateDataBase.contains(by: key) {
                    item.countryName = self.getCountryDescription(for: key)
                }

                items.append(item)
            }
            
            return items
        }
        return []
    }
}

// MARK: - Utility

extension RatesRepository {
    
    private func getCountryDescription(for currency: String) -> String? {
        
        let shortCode = String(currency.prefix(2))
        
        if let jsonPath: String = Bundle.main.path(forResource: "CountryAbbr", ofType: "json"),
            let jsonData: Data = NSData(contentsOfFile: jsonPath) as Data? {
            
            do {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                    let json = jsonResponse as? [String: Any] {
                    return json[shortCode] as? String
                }
            }
        }
        return nil
    }
}