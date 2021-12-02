//
//  ChatVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import UIKit
import JGProgressHUD

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
        startListeningConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationLbl.frame = CGRect(x: 10, y: (view.height - 100)/2, width: view.width - 20, height: 100)
    }
    
    @objc private func composeBtnTapped() {
        let vc = NewConversationVC()
        vc.completion = { result in
            let currentConversaitons = self.conversations
            if let targetConversation = currentConversaitons.first(where: {
                $0.otherUserEmail == result.email.safeDatabaseKey()
            }) {
                let vc = ConversationVC(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNew = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.createNewConversation(result: result)
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func createNewConversation(result: SearchResult) {
        let email = result.email.safeDatabaseKey()
        let name = result.name
        DatabaseManager.shared.conversationExists(with: email) { result in
            switch result {
            case .success(let conversationId):
                let vc = ConversationVC(with: email, id: conversationId)
                vc.isNew = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ConversationVC(with: email, id: nil)
                vc.isNew = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    private func setupTableview() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func startListeningConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = email.safeDatabaseKey()
        DatabaseManager.shared.getConversations(for: safeEmail) { result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self.tableView.isHidden = true
                    self.noConversationLbl.isHidden = false
                    return
                }
                self.tableView.isHidden = false
                self.noConversationLbl.isHidden = true
                self.conversations = conversations
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.tableView.isHidden = true
                self.noConversationLbl.isHidden = false
                print(error.localizedDescription)
            }
        }
    }
    
    private func openConversation(with model: Conversation) {
        let vc = ConversationVC(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
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
        openConversation(with: model)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            DatabaseManager.shared.deleteConversation(with: conversationId) { success in
                if success {
                    
                }
            }
            tableView.endUpdates()
        }
    }
}
