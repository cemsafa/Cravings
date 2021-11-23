//
//  Extensions.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-23.
//

import UIKit

extension UIImageView {
    
    func roundedImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
