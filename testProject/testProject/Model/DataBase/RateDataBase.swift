//
//  RateDataBase.swift
//  testProject
//
//  Created by Galina Fedorova on 11.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation
import RealmSwift

struct RateDataBase {    
    private init() {}
}

extension RateDataBase {
    
    static func getItems(onSuccess: (([RateDBModel]) -> ())?, onFail: (() -> ())?) {
        guard let r = try? Realm() else {
            onFail?()
            return
        }
        
        if let list = r.objects(RatesList.self).first {
            onSuccess?(list.items.map({$0}))
        }
    }
    
    static func putItem(item: RateDBModel) {
        guard let r = try? Realm() else { return }
        
        if let list = r.objects(RatesList.self).first {
            if let filterItem = list.items
                .filter({ $0.currency == item.currency}).first {
                try? r.write {
                    filterItem.rate = item.rate
                }
            } else {
                try? r.write {
                    list.items.append(item)
                }
            }
        } else {
            let list = RatesList()
            try? r.write {
                list.items.append(item)
                r.add(list)
            }
        }
    }
    
    static func moveItem(to index: Int, id: String) {
        guard let r = try? Realm() else { return }

        let list = r.objects(RatesList.self).first?.items
        
        if let item = list?.filter({ $0.currency == id }).first,
            let itemIndex = list?.index(of: item) {
            
            do {
                try r.write {
                    list?.move(from: itemIndex, to: index)
                }
            } catch {
                print("не переместилось в начало")
            }
        }
    }
    
    static func contains(by currency: String) -> Bool {
        guard let r = try? Realm() else { return false }
        
        if let list = r.objects(RatesList.self).first {
            if let _ = list.items
                .filter({ $0.currency == currency}).first {
                return true
            }
        }
        return false
    }
    
}
