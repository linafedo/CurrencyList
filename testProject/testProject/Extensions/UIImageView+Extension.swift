//
//  UIImage+Extension.swift
//  testProject
//
//  Created by Galina Fedorova on 06.02.2020.
//  Copyright © 2020 Galina Fedorova. All rights reserved.
//

import Foundation
import UIKit

// MARK: - rounded image view

extension UIImageView {
    
    func makeRounded() {
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
}

// MARK: - load image

extension UIImageView {

    func loadImage(url: URL) {
        ImageLoader.loadImage(url: url) { (image) in
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}
