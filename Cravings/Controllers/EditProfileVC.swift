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
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
        editProfileImage.roundedImage()
        
        let addPhotoTappedRecognizer = UITapGestureRecognizer(target: self, action: #selector(addPhotoLblTapped))
        addPhotoLbl.isUserInteractionEnabled = true
        addPhotoLbl.addGestureRecognizer(addPhotoTappedRecognizer)
        
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func backButton(_ sender: UIButton) {
    }
    
   
    @IBAction func addPhotoLblTapped (sender: UITapGestureRecognizer) {
        
        picker.allowsEditing = true
        //picker.sourceType = .camera   //camera will work on real ios device
        picker.delegate = self
        present(picker, animated: true)
        
               
    }
    
    
    
   
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
     
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        editProfileImage.image = image
        
    }
}
