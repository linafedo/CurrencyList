//
//  RateCell.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import UIKit

class RateCell: UITableViewCell {
    
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var rateNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var rateTextField: UITextField!
    
}

extension RateCell {
    
    func setup(model: RateViewModel) {
        self.rateNameLabel.text = model.currencyName
        self.countryNameLabel.text = model.countryName
        self.rateTextField.text = model.rate
        
        if let url = model.imageUrl {
            self.rateImageView.loadImage(url: url)
        }
    }
}
