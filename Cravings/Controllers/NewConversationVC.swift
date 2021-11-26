//
//  NewConversationVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-24.
//

import UIKit
import JGProgressHUD

class NewConversationVC: UIViewController {
    
    public var completion: (([String: String]) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var didFetched = false
    
    private let searchbar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Search users"
        return searchbar
    }()
    
    private let tableview: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultLbl: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No result"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultLbl)
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        searchbar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchbar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchbar.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
        noResultLbl.frame = CGRect(x: view.frame.width/4, y: (view.frame.height-200)/2, width: view.frame.width/2, height: 200)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension NewConversationVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        searchUser(with: text)
    }
    
    func searchUser(with querry: String) {
        if didFetched {
            filterUsers(with: querry)
        } else {
            DatabaseManager.shared.getUsers { result in
                switch result {
                case .success(let collection):
                    self.didFetched = true
                    self.users = collection
                    self.filterUsers(with: querry)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func filterUsers(with querry: String) {
        guard didFetched else { return }
        self.spinner.dismiss()
        let results: [[String: String]] = self.users.filter {
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(querry.lowercased())
        }
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noResultLbl.isHidden = false
            self.tableview.isHidden = true
        } else {
            self.noResultLbl.isHidden = true
            self.tableview.isHidden = false
            self.tableview.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NewConversationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userData = results[indexPath.row]
        dismiss(animated: true) {
            self.completion?(userData)
        }
    }
}
