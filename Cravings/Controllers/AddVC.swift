//
//  AddVC.swift
//  Cravings
//
//  Created by Ma. Kristina Ginga on 2021-11-16.
//

import UIKit

class AddVC: UIViewController {
    
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var imagesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageView.backgroundColor = .secondarySystemBackground
            
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        //picker.sourceType = .camera //will work on real ios device
        picker.delegate = self
        present(picker, animated: true)
        
    
    }
    
   
}

extension AddVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
     
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        addImageView.image = image
        
    }
    
    
    
}
