//
//  ChatVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import JGProgressHUD

public struct Conversation {
    public let id: String
    public let name: String
    public let otherUserEmail: String
    public let latestMessage: LatestMessage
}

public struct LatestMessage {
    public let date: String
    public let text: String
    public let isRead: Bool
}

class ChatVC: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ChatTVCell.self, forCellReuseIdentifier: ChatTVCell.identifier)
        return table
    }()
    
    private let noConversationLbl: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No conversation"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeBtnTapped))
        view.addSubview(tableView)
        view.addSubview(noConversationLbl)
        setupTableview()
        fetchConversations()
        startListeningConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc private func composeBtnTapped() {
        let vc = NewConversationVC()
        vc.completion = { result in
            self.createNewConversation(result: result)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let email = result["email"], let name = result["name"] else { return }
        let vc = ConversationVC(with: email, id: nil)
        vc.isNew = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    private func setupTableview() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }
    
    private func startListeningConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = email.safeDatabaseKey()
        DatabaseManager.shared.getConversations(for: safeEmail) { result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else { return }
                self.conversations = conversations
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTVCell.identifier, for: indexPath) as! ChatTVCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ConversationVC(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
