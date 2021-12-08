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
import FirebaseAuth
import JGProgressHUD
import SwiftUI

class LoginVC: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet var facebookLoginBtn: FBLoginButton!
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    @IBOutlet weak var forgotLbl: UILabel!
    @IBOutlet weak var signupLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let token = AccessToken.current, !token.isExpired {
//            let token = token.tokenString
//
//            let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
//            request.start { connection, result, error in
//                print("\(result)")
//            }
//        } else {
//            facebookLoginBtn = FBLoginButton()
//            facebookLoginBtn.delegate = self
//        }
        
        facebookLoginBtn = FBLoginButton()
        facebookLoginBtn.permissions = ["email, public_profile"]
        facebookLoginBtn.delegate = self
        
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
        navigationController?.pushViewController(registerVC, animated: true)
    }

    @IBAction func loginBtnTapped(_ sender: UIButton) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        spinner.show(in: view)
        
        AuthManager.shared.loginUser(email: email, password: password) { success,error in
            DispatchQueue.main.async {
                self.spinner.dismiss()
                if success {
                    let safeEmail = email.safeDatabaseKey()
                    DatabaseManager.shared.getData(for: safeEmail) { result in
                        switch result {
                        case .success(let data):
                            guard let userData = data as? [String: Any], let fullname = userData["full_name"] as? String else { return }
                            UserDefaults.standard.set(fullname, forKey: "fullname")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    UserDefaults.standard.set(email, forKey: "email")
                    self.navigationController?.dismiss(animated: true, completion: nil)
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
        loginManager.logIn(permissions: ["email", "public_profile"], from: self) { result, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                guard let token = result?.token?.tokenString else { return }
                
                let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
                request.start { _, result, error in
                    guard let result = result as? [String: Any], error == nil else {
                        print("Facebook graph request failed")
                        return
                    }
                    
                    guard let fullname = result["name"] as? String, let email = result["email"] as? String, let picture = result["picture"] as? [String: Any], let data = picture["data"] as? [String: Any], let pictureURL = data["url"] as? String else {
                        print("Failed to get name and email")
                        return
                    }
                    
                    let userName = fullname.replacingOccurrences(of: " ", with: "").lowercased()
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(fullname, forKey: "fullname")
                    DatabaseManager.shared.canCreateUser(with: email) { success in
                        if !success {
                            guard let url = URL(string: pictureURL) else { return }
                            
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                guard let data = data else { return }
                                let user = User(email: email, username: userName, fullname: fullname)
                                DatabaseManager.shared.insertNewUser(with: user) { success in
                                    if success {
                                        StorageManager.shared.uploadProfilePicture(with: data) { result in
                                            switch result {
                                            case .success(let downloadURL):
                                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                            case .failure(let error):
                                                print(error.localizedDescription)
                                            }
                                        }
                                    }
                                }
                            }.resume()
                        }
                    }
                    
                    let credential = FacebookAuthProvider.credential(withAccessToken: token)
                    Auth.auth().signIn(with: credential) { result, error in
                        guard result != nil, error == nil else {
                            print("Facebook login failed")
                            return
                        }
                        print("Facebook login successful")
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
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
            
            guard let email = user?.profile?.email, let fullName = user?.profile?.name else {
                return
            }
            
            let userName = fullName.replacingOccurrences(of: " ", with: "").lowercased()
            
            let googleUser = User(email: email, username: userName, fullname: fullName)
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(fullName, forKey: "fullname")
            DatabaseManager.shared.canCreateUser(with: email) { success in
                if !success {
                    DatabaseManager.shared.insertNewUser(with: googleUser) { success in
                        if success {
                            if ((user?.profile?.hasImage) != nil) {
                                guard let url = user?.profile?.imageURL(withDimension: 200) else { return }
                                
                                URLSession.shared.dataTask(with: url) { data, _, _ in
                                    guard let data = data else { return }
                                    
                                    let filename = googleUser.profilePictureFilename
                                    StorageManager.shared.uploadProfilePicture(with: data) { result in
                                        switch result {
                                        case .success(let downloadURL):
                                            UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        case .failure(let error):
                                            print(error.localizedDescription)
                                        }
                                    }
                                }.resume()
                            }
                        }
                    }
                }
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - LoginButtonDelegate
extension LoginVC: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
}
