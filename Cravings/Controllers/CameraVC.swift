//
//  CameraVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit

class CameraVC: UIViewController {
    
    @IBOutlet weak var addImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageView.backgroundColor = .secondarySystemBackground
            
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        //picker.sourceType = .camera   //camera will work on real ios device
        picker.delegate = self
        present(picker, animated: true)
        
    
    }
    
   
}

extension CameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
