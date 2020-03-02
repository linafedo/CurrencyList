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

    private var timer = Timer()
    private var currentKey: String?
    
    var items = [RateViewModel]()
    
    var numberOfItems: Int {
        return self.items.count
    }
    
    weak var viewDelegate: RatesVMDelegate?
        
    init(viewDelegate: RatesVMDelegate) {
        self.viewDelegate = viewDelegate
        
        self.getLocalRates()
        self.scheduledTimerWithTimeInterval()
    }
    
    private func getLocalRates(refresh: Bool = false) {
        self.repository.getLocalRates { [weak self] (models) in
            guard let self = self else { return }
            let newItems = self.map(items: models)
            
            if self.items.isEmpty {
                self.currentKey = newItems.first?.currencyName
            }
            let needRefresh = (newItems.count > self.items.count) ? true : false
            
            self.items = newItems
            needRefresh || refresh ? self.viewDelegate?.refreshAll() : self.viewDelegate?.updateCurrentData()
        }
    }
        
    @objc private func fetchRemoteRates() {
        self.repository.fetchRemotesRates(for: self.currentKey) { [weak self] in
            self?.getLocalRates()
        }
    }
    
    private func scheduledTimerWithTimeInterval() {
        self.timer = Timer.scheduledTimer(timeInterval: 2,
                                          target: self,
                                          selector: #selector(self.fetchRemoteRates),
                                          userInfo: nil,
                                          repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    func didSelectRow(at index: Int) {
        if index <= self.items.count - 1 {
            
            let item = self.items[index]
            self.currentKey = item.currencyName
            self.repository.moveRate(to: 0, id: item.currencyName)
            self.getLocalRates(refresh: true)
        }
    }
    
    func recalculateRate(value: String?) {
        if let id = self.currentKey,
            let value = value,
            let rate = Double(value) {
            
            self.repository.updateRate(for: id, value: rate)
            self.getLocalRates()
        }
    }
        
}

// MARK: - Map

extension RatesViewModel {
    
    func map(items: [RateItem]) -> [RateViewModel] {
        var models = [RateViewModel]()
        
        let currencyRate = items.filter({ $0.currency == self.currentKey }).first?.rate ?? 1
        print("self.currentKey - \(currentKey)", currencyRate)
        
        for item in items {
            print(item.currency)
            let code = String(item.currency.prefix(2))
            let imageUrl = Utility.getImageUrl(for: code)
            
            let multiplier = (item.currency == self.currentKey) ? 1 : currencyRate
            print("multiplier - ", multiplier)
            print("item.rate - ", item.rate)

            let rate = round(1000 * item.rate * multiplier) / 1000
            print("rate - ", rate)
            print("\n")

            
            let model = RateViewModel(currencyName: item.currency,
                                      countryName: item.countryName,
                                      rate: String(rate),
                                      imageUrl: imageUrl)
            models.append(model)
        }
        print("\n")

        
        return models
    }
    
}
