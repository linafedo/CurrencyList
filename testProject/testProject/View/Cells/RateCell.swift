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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rateTextField.delegate = self
    }
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

extension RateCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet(charactersIn:".0123456789")
        let characterSet = CharacterSet(charactersIn: string)

        guard string == "." else {
          return allowedCharacters.isSuperset(of: characterSet)
        }
        
        let point = (textField.text?.contains(".") == true) ? false : true
        return point
    }
}
