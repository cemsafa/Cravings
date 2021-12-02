//
//  ConversationVC.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-24.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit

class ConversationVC: MessagesViewController {
    
    public var isNew = false
    public let otherUserEmail: String
    
    private var conversationId: String?
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var messages = [Message]()
    private var senderPhotoURL: URL?
    private var receiverPhotoURL: URL?
    
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
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
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { _ in
            self.presentInputAC()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputAC() {
        let action = UIAlertController(title: "Attachment", message: "Select type of attachment", preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in
            self.presentPhotoAC()
        }))
        action.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
            self.presentVidoeAC()
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(action, animated: true)
    }
    
    private func presentPhotoAC() {
        let action = UIAlertController(title: "Photo", message: "Select photo from", preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(action, animated: true)
    }
    
    private func presentVidoeAC() {
        let action = UIAlertController(title: "Video", message: "Select video from", preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Library", style: .default, handler: { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(action, animated: true)
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
                    let newConversationId = "conversation_\(message.messageId)"
                    self.conversationId = newConversationId
                    self.listenMessages(id: newConversationId, shouldScrollToBottom: true)
                    self.messageInputBar.inputTextView.text = nil
                } else {
                    
                }
            }
        } else {
            guard let conversationId = conversationId, let name = self.title else { return }
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message) { success in
                if success {
                    self.messageInputBar.inputTextView.text = nil
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == currentSender().senderId {
            if let currentUserPhotoURL = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserPhotoURL, completed: nil)
            } else {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
                let safeEmail = email.safeDatabaseKey()
                let path = "images/\(safeEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path, completion: { result in
                    switch result {
                    case .success(let url):
                        self.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            }
        } else {
            if let receiverUserPhotoURL = self.receiverPhotoURL {
                avatarView.sd_setImage(with: receiverUserPhotoURL, completed: nil)
            } else {
                let email = self.otherUserEmail
                let safeEmail = email.safeDatabaseKey()
                let path = "images/\(safeEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path, completion: { result in
                    switch result {
                    case .success(let url):
                        self.receiverPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ConversationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageID = createMessageId(), let conversationID = conversationId, let name = self.title, let sender = self.sender else { return }
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            let filename = "photo_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".png"
            StorageManager.shared.uploadMessagePhoto(with: imageData, filename: filename) { result in
                switch result {
                case .success(let urlString):
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus") else { return }
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let message = Message(sender: sender, messageId: messageID, sentDate: Date(), kind: .photo(media))
                    DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: self.otherUserEmail, name: name, newMessage: message) { success in
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else if let video = info[.mediaURL] as? URL {
            let filename = "video_message_" + messageID.replacingOccurrences(of: " ", with: "-") + ".mov"
            StorageManager.shared.uploadMessageVideo(with: video, filename: filename) { result in
                switch result {
                case .success(let urlString):
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus") else { return }
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let message = Message(sender: sender, messageId: messageID, sentDate: Date(), kind: .video(media))
                    DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: self.otherUserEmail, name: name, newMessage: message) { success in
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MessageCellDelegate
extension ConversationVC: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            let vc = PhotoViewerVC(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else { return }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
