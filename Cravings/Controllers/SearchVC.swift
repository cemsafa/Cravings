//
//  SearchVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import Fuzzywuzzy_swift

class SearchVC: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTableView: UITableView!
    
    let searchController = UISearchController()
    
    var data = [String]()
    var filteredData = [String]()
    private var users = [[String: String]]()
    
    private var searchResults = [[String: String]]() {
        didSet {
            searchTableView.reloadData()
        }
    }
//    String.fuzzPartialRatio(str1: "some text here", str2: "I found some text here!")
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(UINib.init(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpData()
    }
    
    func setUpData () {
        DatabaseManager.shared.getUsers { result in
            switch result {
            case .success(let collection):
                self.users = collection
                self.searchResults = self.users
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        updateSearchResultsWithText(searchText: text)
    }
    
    func updateSearchResultsWithText(searchText: String) {
        self.searchResults = self.users.filter({ String.fuzzPartialRatio(str1: searchText, str2: ($0["username"] ?? "")) > 70 })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        let item = self.searchResults[indexPath.row]
        cell.searchTitleLabel.text = item["username"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.searchResults[indexPath.row]
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.email = item[UserProfileKeys.email.rawValue] ?? ""
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
