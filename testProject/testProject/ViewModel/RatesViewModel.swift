//
//  RatesViewModel.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import UIKit

class RatesViewModel {
    
    private let repository: RepositoryProtocol = RatesRepository()

    var timer = Timer()
    
    var items = [RateViewModel]() {
        didSet {
            self.viewDelegate?.reloadData()
        }
    }
    
    weak var viewDelegate: RatesVCDelegate?
    
    var numberOfItems: Int {
        return self.items.count
    }
    
    init(viewDelegate: RatesVCDelegate) {
        self.viewDelegate = viewDelegate
        
        self.getLocalRates()
        self.fetchRemoteRates()
        self.scheduledTimerWithTimeInterval()
    }
    
    private func getLocalRates() {
        self.repository.getLocalRates { [weak self] (models) in
            guard let self = self else { return }
            self.items = self.map(items: models)
        }
    }
    
    @objc private func fetchRemoteRates() {
        self.repository.fetchRemotesRates() { [weak self] in
            guard let self = self else { return }
            self.getLocalRates()
        }
    }
    
    private func scheduledTimerWithTimeInterval() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.5,
                                          target: self,
                                          selector: #selector(self.fetchRemoteRates),
                                          userInfo: nil,
                                          repeats: true)
    }
    
}

// MARK: - Map

extension RatesViewModel {
    
    func map(items: [RateItem]) -> [RateViewModel] {
        var models = [RateViewModel]()
        
        for item in items {
            let code = String(item.currencyName.prefix(2))
            let imageUrl = Utility.getImageUrl(for: code)
            
            let model = RateViewModel(currencyName: item.currencyName,
                                      countryName: item.currencyName + "???",
                                      rate: String(item.rate),
                                      imageUrl: imageUrl)
            models.append(model)
        }
        
        return models
    }
    
}
