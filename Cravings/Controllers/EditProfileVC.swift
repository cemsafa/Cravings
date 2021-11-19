//
//  EditProfileVC.swift
//  Cravings
//
//  Created by Ma. Kristina Ginga on 2021-11-19.
//

import UIKit

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var addPhotoLbl: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var webYTField: UITextField!
    @IBOutlet weak var aboutMeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        editProfileImage.roundedImage()

       
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func addPhotoLblTapped (sender: UITapGestureRecognizer) {
        
    }
    
    
    
    
    
    
}
