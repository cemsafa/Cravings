//
//  ConversationVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-24.
//

import UIKit
import MessageKit
import InputBarAccessoryView

public struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link"
        case .custom(_):
            return "custom"
        }
    }
}

public struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

class ConversationVC: MessagesViewController {
    
    public var isNew = false
    public let otherUserEmail: String
    
    private let conversationId: String?
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var messages = [Message]()
    
    private var sender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String, let fullname = UserDefaults.standard.value(forKey: "fullname") as? String else {
            return nil
        }
        let safeEmail = email.safeDatabaseKey()
        return Sender(photoURL: "", senderId: safeEmail, displayName: fullname)
    }
    
    init(with email: String, id: String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
    private func createMessageId() -> String? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let currentUserEmail = email.safeDatabaseKey()
        let dateString = Self.dateFormatter.string(from: Date())
        let newId = "\(otherUserEmail.safeDatabaseKey())_\(currentUserEmail)_\(dateString)"
        return newId
    }
    
    private func listenMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getMessages(with: id) { result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else { return }
                self.messages = messages
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ConversationVC: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let sender = self.sender, let messageId = createMessageId() else { return }
        let message = Message(sender: sender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        if isNew {
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, name: self.title ?? "User") { success in
                if success {
                    self.isNew = false
                } else {
                    
                }
            }
        } else {
            guard let conversationId = conversationId, let name = self.title else { return }
            DatabaseManager.shared.sendMessage(to: conversationId, name: name, newMessage: message) { success in
                if success {
                    
                } else {
                    
                }
            }
        }
    }
}

// MARK: - MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate
extension ConversationVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = sender {
            return sender
        }
        fatalError("Sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
