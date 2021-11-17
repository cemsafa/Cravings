//
//  HomeVC.swift
//  Cravings
//
//  Created by Ma. Kristina Ginga on 2021-11-16.
//

import UIKit


class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var foodImageCollectionView: UICollectionView!
    
    //statically added images for UI testing only
    let foods = ["dessert", "ramen", "pancake" ]
    
    let foodImages: [UIImage] = [
        UIImage(named: "dessert")!,
        UIImage(named: "ramen")!,
        UIImage(named: "pancake")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodImageCollectionView.dataSource = self
        foodImageCollectionView.delegate = self

      
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foods.count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = foodImageCollectionView.dequeueReusableCell(withReuseIdentifier: "foodImageCell", for: indexPath) as! FoodImageCollectionViewCell
        cell.foodImageView.image = foodImages[indexPath.item]
        
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 5, right: 2)
//        layout.minimumInteritemSpacing = 2
//        layout.minimumLineSpacing = 5
//        layout.scrollDirection = .vertical
//        collectionView.collectionViewLayout = layout
        
            
        
                
                return cell
        
    }
    
    
   

}
