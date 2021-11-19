//
//  EditProfileVC.swift
//  Cravings
//
//  Created by Ma. Kristina Ginga on 2021-11-19.
//

import UIKit

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var editProfileImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        editProfileImage.roundedImage()

       
    }
    

}
