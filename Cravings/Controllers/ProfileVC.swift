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
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var aboutMeLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var email: String = userEmail {
        didSet {
            chatButton.isHidden = email == userEmail
            followButton.isHidden = email == userEmail
            editButton.isHidden = email != userEmail
        }
    }
    
    var posts: [Post] = [Post]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var followers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        
        profileImage.roundedImage()
        
        collectionView?.register(UINib.init(nibName: "AddPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AddPostCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUserData()
    }
    
    func setUpUserData() {
        DatabaseManager.shared.getUserProfile(with: userEmail, completion: { success, userData in
            if success, let data = userData {
                self.nameLbl.text = data[UserProfileKeys.fullName.rawValue]
                self.titleLbl.text = data[UserProfileKeys.bio.rawValue]
                self.aboutMeLbl.text = data[UserProfileKeys.aboutMe.rawValue]
                self.followersLbl.text = "\(self.followers.count) followers"
                StorageManager.shared.getProfilePictureURL { result in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            self.profileImage.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(_):
                        break
                    }
                }
            }
        })
        getUserPosts()
    }
    
    func getUserPosts() {
        DatabaseManager.shared.getUserPosts { posts in
            self.posts = posts
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

extension ProfileVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension ProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPostCollectionViewCell", for: indexPath) as? AddPostCollectionViewCell,
              indexPath.row < posts.count,
              posts[indexPath.row].media.count > 0 else {
            return UICollectionViewCell()
        }
        let post = posts[indexPath.row]
        cell.imageURL = post.media[0]
        return cell
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
    
}
