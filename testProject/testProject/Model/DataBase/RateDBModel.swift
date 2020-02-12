//
//  RateDBModel.swift
//  testProject
//
//  Created by Galina Fedorova on 11.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation
import RealmSwift

class RatesList: Object {
    let items = List<RateDBModel>()
}

class RateDBModel: Object {
    @objc dynamic var currency: String = ""
    @objc dynamic var countryName: String?
    @objc dynamic var rate: Double = 0

    override static func primaryKey() -> String? {
        return "currency"
    }
}
