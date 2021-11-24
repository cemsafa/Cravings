//
//  DetailVC.swift
//  Cravings
//
//  Created by Ma. Kristina Ginga on 2021-11-23.
//

import UIKit
import SwiftUI

class DetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var captionLbl: UILabel!
    
    
    var comments = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.roundedImage()
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        
      
    }
    
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func likeBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func commentBtnPressed(_ sender: UIButton) {
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        cell.textLabel?.text = comments[indexPath.row]
                
        return cell
        
    }
    
    
    
    
}

