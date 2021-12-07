//
//  ProfileVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class ProfileVC: UIViewController {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    
    var collectionView: UICollectionView?
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Profile"
        profileImage.roundedImage()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: width / 2, height: width / 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView?.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserData()
    }
    
    func getUserData() {
        let email = UserDefaults.standard.value(forKey: UserProfileKeys.email.rawValue) as? String ?? ""
        DatabaseManager.shared.getData(for: email.safeDatabaseKey()) { result in
            switch result {
            case .success(let data):
                guard let userData = data as? [String: Any], let fullname = userData[UserProfileKeys.fullName.rawValue] as? String else { return }
                UserDefaults.standard.set(fullname, forKey: "fullname")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func signoutBtnPressed(_ sender: UIBarButtonItem) {
        UserDefaults.standard.setValue(nil, forKey: "email")
        UserDefaults.standard.setValue(nil, forKey: "name")
        GIDSignIn.sharedInstance.signOut()
        FBSDKLoginKit.LoginManager().logOut()
        AuthManager.shared.logOut { success in
            if success {
                guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") else {
                    return
                }
                let nav = UINavigationController(rootViewController: loginVC)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
            }
        }
    }
    
    @IBAction func editProfileBtnPressed(_ sender: UIButton) {
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chatBtnPressed(_ sender: UIButton) {
        
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func followBtnPressed(_ sender: UIButton) {
        
    }
  
}

extension ProfileVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth/3, height: collectionViewWidth/3)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
