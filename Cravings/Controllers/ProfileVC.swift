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
import JGProgressHUD

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
    
    private let spinner = JGProgressHUD(style: .dark)
    
    var email: String = userEmail
    
    var posts: [Post] = [Post]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var isLoggedInUser: Bool {
        return userEmail == email
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
        if email.isEmpty {
            email = userEmail
        }
        setUpUserData()
    }
    
    func setUpUserData() {
        spinner.show(in: view)
        DatabaseManager.shared.getUserProfile(with: email, completion: { success, userData in
            if success, let data = userData {
                self.nameLbl.text = data.fullName
                self.titleLbl.text = data.bio
                self.aboutMeLbl.text = data.aboutMe
                self.followersLbl.text = "\(self.followers.count) followers"
                
                self.chatButton.isHidden = self.isLoggedInUser
                self.followButton.isHidden = self.isLoggedInUser
                self.editButton.isHidden = !self.isLoggedInUser
                
                StorageManager.shared.getProfilePictureURL { result in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            self.profileImage.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(_):
                        self.profileImage.image = nil
                        break
                    }
                }
            }
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
        })
        getUserPosts()
    }
    
    func getUserPosts() {
        DatabaseManager.shared.getUserPosts(email: self.email, completion: { posts in
            self.posts = posts
        })
    }
    
    @IBAction func signoutBtnPressed(_ sender: UIBarButtonItem) {
        UserDefaults.standard.setValue(nil, forKey: UserProfileKeys.email.rawValue)
        UserDefaults.standard.setValue(nil, forKey: "name")
        email = ""
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
        vc.hidesBottomBarWhenPushed = true
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
