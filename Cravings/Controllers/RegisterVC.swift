//
//  RegisterVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit

class RegisterVC: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let loginTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(loginLblTapped))
        loginLbl.isUserInteractionEnabled = true
        loginLbl.addGestureRecognizer(loginTapRecognizer)
    }
    
    @IBAction func loginLblTapped(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
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
        
        AuthManager.shared.regsiterNewUser(fullname: fullName, username: userName, email: email, password: password) { success in
            if success {
                guard let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") else { return }
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: false)
            } else {
                self.registerAlert(message: "Error creating user.")
            }
        }
    }
    
    func registerAlert(message: String = "Please fill all fields to create a new account.") {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}
