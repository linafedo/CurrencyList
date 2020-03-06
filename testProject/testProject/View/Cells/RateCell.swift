//
//  RateCell.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import UIKit

class RateCell: UITableViewCell {
    
    @IBOutlet private weak var rateImageView: UIImageView!
    @IBOutlet private weak var rateNameLabel: UILabel!
    @IBOutlet private weak var countryNameLabel: UILabel!
    @IBOutlet private weak var rateTextField: UITextField!
    
    private var textFieldDidChange: ((String?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rateImageView.makeRounded()
        self.rateTextField.delegate = self
        self.rateTextField.isUserInteractionEnabled = false
        self.rateTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
}

extension RateCell {
    
    func setup(model: RateViewModel, completion: ((String?) -> ())?) {
        self.rateNameLabel.text = model.currencyName
        self.countryNameLabel.text = model.countryName
        self.rateTextField.text = model.rate
        self.textFieldDidChange = completion
        
        if let url = model.imageUrl {
            self.rateImageView.loadImage(url: url)
        }
    }
    
    func makeInteractive() {
        self.rateTextField.isUserInteractionEnabled = true
    }
}

extension RateCell: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.textFieldDidChange?(textField.text)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet(charactersIn:".0123456789")
        let characterSet = CharacterSet(charactersIn: string)

        guard string == "." else {
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        let point = (textField.text?.contains(".") == false && textField.text != "") ? true : false
        
        return point
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
}
