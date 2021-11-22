//
//  HomeVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import FirebaseAuth

class HomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
    }
    
    func handleNotAuthenticated() {
        if Auth.auth().currentUser == nil {
            guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") else { return }
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
}
