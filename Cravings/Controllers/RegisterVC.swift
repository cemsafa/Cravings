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
    }
}
