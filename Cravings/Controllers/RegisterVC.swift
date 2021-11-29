//
//  RegisterVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterVC: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signupBtnTapped(_ sender: UIButton) {
        nameField.resignFirstResponder()
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let fullName = nameField.text,
              let userName = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !fullName.isEmpty,
              !userName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
                  registerAlert()
                  return
              }
        
        spinner.show(in: view)
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(fullName, forKey: "fullname")
        DatabaseManager.shared.canCreateUser(with: email) { success in
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            guard !success else {
                self.registerAlert(message: "Email already has an account")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                guard result != nil, error == nil else {
                    self.registerAlert(message: error!.localizedDescription)
                    return
                }
                
                DatabaseManager.shared.insertNewUser(with: User(email: email, username: userName, fullname: fullName)) { success in
                    if success {
                        
                    }
                }
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func registerAlert(message: String = "Please fill all fields to create a new account.") {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}
