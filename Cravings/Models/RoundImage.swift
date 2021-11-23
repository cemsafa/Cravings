//
//  RoundImage.swift
//  Cravings
//
//  Created by Ma. Kristina Ginga on 2021-11-19.
//

import UIKit

extension UIImageView {
    
    func roundedImage() {
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        
        
        
    }
    
    
    
}
