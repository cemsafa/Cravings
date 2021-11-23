//
//  DetailVC.swift
//  Cravings
//
//  Created by Ma. Kristina Ginga on 2021-11-23.
//

import UIKit
import SwiftUI

class DetailVC: UIViewController {
    
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var captionLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
    }
    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func likeBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func commentBtnPressed(_ sender: UIButton) {
    }
}

