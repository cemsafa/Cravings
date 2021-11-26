//
//  EditProfileVC.swift
//  Cravings
//
//  Created by Ma. Kristina Ginga on 2021-11-19.
//

import UIKit

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var editProfileImage: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var webYTField: UITextField!
    @IBOutlet weak var aboutMeField: UITextField!
    
    var fullName: String {
        return nameField.text ?? ""
    }
    
    var userName: String {
        return usernameField.text ?? ""
    }
    
    var bio: String {
        return titleField.text ?? ""
    }
    
    var websiteLink: String {
        return webYTField.text ?? ""
    }
    
    var aboutMe: String {
        return aboutMeField.text ?? ""
    }
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editProfileImage.roundedImage()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // api call
        // but populate date first
        if isDataValid {
            DatabaseManager.shared.updateUserProfile(fullName: fullName, bio: bio, userName: userName, websiteLink: websiteLink, aboutMe: aboutMe) { success in
                if success {
                    self.showAlert(message: "Profile Updated", true)
                }
                else {
                    self.showAlert(message: "Error in saving data")
                }
            }
        }
        else {
            // show alert
            showAlert(message: "please fill all the fields")
        }
    }
    
    func showAlert(message: String, _ shouldPop: Bool = false) {
        let alert = UIAlertController(title: message, message: "",preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            if shouldPop {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                alert.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    var isDataValid: Bool {
        return !(fullName.isEmpty || userName.isEmpty || bio.isEmpty || aboutMe.isEmpty)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func editPhotoLblTapped (_ sender: UIButton) {
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
