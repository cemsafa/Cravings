//
//  LoginVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import Firebase
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
        
        if let token = AccessToken.current, !token.isExpired {
            let token = token.tokenString
            
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
            request.start { connection, result, error in
                print("\(result)")
            }
        } else {
            facebookLoginBtn = FBLoginButton()
            facebookLoginBtn.delegate = self
        }
        
        let forgotTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(forgotLblTapped))
        forgotLbl.isUserInteractionEnabled = true
        forgotLbl.addGestureRecognizer(forgotTapRecognizer)
        
        let signupTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(signupLblTapped))
        signupLbl.isUserInteractionEnabled = true
        signupLbl.addGestureRecognizer(signupTapRecognizer)
    }
    
    @IBAction func forgotLblTapped(sender: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
        guard let email = emailField.text else { return }
        AuthManager.shared.sendPasswordReset(withEmail: email) { error in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Success", message: "Please check your email", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signupLblTapped(sender: UITapGestureRecognizer) {
        guard let registerVC = storyboard?.instantiateViewController(withIdentifier: "registerVC") else { return }
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true, completion: nil)
    }

    @IBAction func loginBtnTapped(_ sender: UIButton) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text else { return }
        AuthManager.shared.loginUser(email: email, password: password) { success,error in
            DispatchQueue.main.async {
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Log In Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction func facebookLoginBtnTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email" , "public_profile"], from: self) { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                print("Log In Complete")
            }
        }
    }
    
    @IBAction func googleLoginBtnTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print(result ?? "none")
            }
        }
    }
}

// MARK: - LoginButtonDelegate
extension LoginVC: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
        request.start { connection, result, error in
            print("\(result)")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
}
