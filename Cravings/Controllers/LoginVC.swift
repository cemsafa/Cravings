//
//  LoginVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet var facebookLoginBtn: FBLoginButton!
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    @IBOutlet weak var forgotLbl: UILabel!
    @IBOutlet weak var signupLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        facebookLoginBtn = FBLoginButton()
        facebookLoginBtn.permissions = ["email,public_profile"]
        
        let forgotTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(forgotLblTapped))
        forgotLbl.isUserInteractionEnabled = true
        forgotLbl.addGestureRecognizer(forgotTapRecognizer)
        
        let signupTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(signupLblTapped))
        signupLbl.isUserInteractionEnabled = true
        signupLbl.addGestureRecognizer(signupTapRecognizer)
    }
    
    @IBAction func forgotLblTapped(sender: UITapGestureRecognizer) {
        AuthManager.shared.sendPasswordReset(withEmail: emailField.text!) { error in
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signupLblTapped(sender: UITapGestureRecognizer) {
        let registerVC = RegisterVC()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true, completion: nil)
    }

}
