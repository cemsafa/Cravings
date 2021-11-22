//
//  SearchVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit

class SearchVC: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTableView: UITableView!
    
    let searchController = UISearchController()
    
    var data = [String]()
    var filteredData = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setUpData()
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        title = "Search"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
       
     

    }
    
    // added for UI testing purpose
    func setUpData () {
        data.append("pasta")
        data.append("ice cream")
        data.append("cupcake")
        data.append("milkshake")
        data.append("mojito")
        data.append("cheescake")
        data.append("pizza")
        data.append("coffee")
        
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        print(text)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }

}
