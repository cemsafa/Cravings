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
        
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            let width = UIScreen.main.bounds.width
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            layout.itemSize = CGSize(width: width / 2, height: width / 2)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionView?.collectionViewLayout = layout
    }
    
    @IBAction func signoutBtnPressed(_ sender: UIBarButtonItem) {
        
        GIDSignIn.sharedInstance.signOut()
        
        FBSDKLoginKit.LoginManager().logOut()
        
        AuthManager.shared.logOut { success in
            guard !success else {
                guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") else { return }
                let nav = UINavigationController(rootViewController: loginVC)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true)
                return
            }
        }
    }
    
    @IBAction func editProfileBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func chatBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func followBtnPressed(_ sender: UIButton) {
    }
    

    
  
}

extension ProfileVC : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
