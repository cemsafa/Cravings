//
//  ProfileVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit

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
            layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
            layout.itemSize = CGSize(width: width / 2, height: width / 2)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            collectionView?.collectionViewLayout = layout
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
        
        return UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
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
