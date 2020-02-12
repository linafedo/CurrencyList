//
//  Utility.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation

struct Utility {

    private init() {}
    
    static let baseRequestUrl = "https://revolut.duckdns.org"
    
    static func getImageUrl(for code: String) -> URL? {
        let urlStr = "https://www.countryflags.io/\(code)/flat/64.png"
        return URL(string: urlStr)
    }
    
}
