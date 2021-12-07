//
//  DatabaseManager.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import Foundation
import FirebaseDatabase
import CoreMedia
import RealmSwift
import AVFoundation
import UIKit
import FirebaseStorage
import MessageKit
import FirebaseFirestore

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    public func canCreateUser(with email: String, completion: @escaping (Bool) -> Void) {
        database.child(email.safeDatabaseKey()).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func insertNewUser(with user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.email.safeDatabaseKey()).setValue([
            "user_name": user.username,
            "full_name": user.fullname
        ]) { error, _ in
            guard error == nil else {
                print("Failed writing into database")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var collection = snapshot.value as? [[String: String]] {
                    let newElement = [
                        "name": user.fullname,
                        "email": user.email,
                        "username": user.username
                    ]
                    collection.append(newElement)
                    self.database.child("users").setValue(collection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                } else {
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.fullname,
                            "email": user.email,
                            "username": user.username
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
            completion(true)
        }
    }
    
    public func getUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String, let fullname = UserDefaults.standard.value(forKey: "fullname") as? String else {
            return
        }
        let currentEmail = email.safeDatabaseKey()
        let ref = database.child("\(currentEmail)")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ConversationVC.dateFormatter.string(from: messageDate)
            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail.safeDatabaseKey(),
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let receiverNewConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": currentEmail,
                "name": fullname,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            self.database.child("\(otherUserEmail.safeDatabaseKey())/conversations").observeSingleEvent(of: .value) { snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    conversations.append(receiverNewConversationData)
                    self.database.child("\(otherUserEmail.safeDatabaseKey())/conversations").setValue([conversations])
                } else {
                    self.database.child("\(otherUserEmail.safeDatabaseKey())/conversations").setValue([receiverNewConversationData])
                }
            }
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishCreatingConversaitons(conversationId: conversationId, name: name, firstMessage: firstMessage, completion: completion)
                }
            } else {
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self.finishCreatingConversaitons(conversationId: conversationId, name: name, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    public func getConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email.safeDatabaseKey())/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String, let name = dictionary["name"] as? String, let otherUserEmail = dictionary["other_user_email"] as? String, let latestMessage = dictionary["latest_message"] as? [String: Any], let date = latestMessage["date"] as? String, let message = latestMessage["message"] as? String, let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            }
            completion(.success(conversations))
        }
    }
    
    public func getMessages(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String, let isRead = dictionary["is_read"] as? Bool, let messageId = dictionary["id"] as? String, let content = dictionary["content"] as? String, let senderEmail = dictionary["sender_email"] as? String, let dateString = dictionary["date"] as? String, let type = dictionary["type"] as? String, let date = ConversationVC.dateFormatter.date(from: dateString) else {
                    return nil
                }
                var kind: MessageKind?
                if type == "photo" {
                    guard let imageUrl = URL(string: content), let placeholder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                } else if type == "video" {
                    guard let videoUrl = URL(string: content), let placeholder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                } else {
                    kind = .text(content)
                }
                guard let finalKind = kind else {
                    return nil
                }
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: finalKind)
            }
            completion(.success(messages))
        }
    }
    
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentEmail = email.safeDatabaseKey()
        database.child("\(conversation)/messages").observeSingleEvent(of: .value) { snapshot in
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            let messageDate = newMessage.sentDate
            let dateString = ConversationVC.dateFormatter.string(from: messageDate)
            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            let currentUserEmail = email.safeDatabaseKey()
            let newMessageElement: [String: Any] = [
                "id": newMessage.messageId,
                "name": name,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false
            ]
            currentMessages.append(newMessageElement)
            self.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                self.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
                    var dbEntryConversations = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0
                        for conversationDict in currentUserConversations {
                            if let currentId = conversationDict["id"] as? String, currentId == conversation {
                                targetConversation = conversationDict
                                break
                            }
                            position += 1
                        }
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            dbEntryConversations = currentUserConversations
                        } else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_email": otherUserEmail.safeDatabaseKey(),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            dbEntryConversations = currentUserConversations
                        }
                    } else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": otherUserEmail.safeDatabaseKey(),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        dbEntryConversations = [
                            newConversationData
                        ]
                    }
                    
                    self.database.child("\(currentEmail)").setValue(dbEntryConversations) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        self.database.child("\(otherUserEmail.safeDatabaseKey())/conversations").observeSingleEvent(of: .value) { snapshot in
                            var dbEntryConversations = [[String: Any]]()
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String: Any]?
                                var position = 0
                                for conversationDict in otherUserConversations {
                                    if let currentId = conversationDict["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDict
                                        break
                                    }
                                    position += 1
                                }
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    dbEntryConversations = otherUserConversations
                                } else {
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": currentEmail.safeDatabaseKey(),
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    dbEntryConversations = otherUserConversations
                                }
                            } else {
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_email": currentEmail.safeDatabaseKey(),
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                dbEntryConversations = [
                                    newConversationData
                                ]
                            }
                            self.database.child("\(otherUserEmail.safeDatabaseKey())").setValue(dbEntryConversations) { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func finishCreatingConversaitons(conversationId: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = ConversationVC.dateFormatter.string(from: messageDate)
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentUserEmail = email.safeDatabaseKey()
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "name": name,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false
        ]
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        database.child("\(conversationId)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func getData(for path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public func deleteConversation(with conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let safeEmail = email.safeDatabaseKey()
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String, id == conversationId {
                        break
                    }
                    positionToRemove += 1
                }
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func conversationExists(with receiverEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let email = receiverEmail.safeDatabaseKey()
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = senderEmail.safeDatabaseKey()
        database.child("\(email)/conversations").observeSingleEvent(of: .value) { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            if let conversation = collection.first(where: {
                guard let targetSender = $0["other_user_email"] as? String else {
                    return false
                }
                return safeEmail == targetSender
            }) {
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseErrors.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DatabaseErrors.failedToFetch))
            return
        }
    }
    
    public enum DatabaseErrors: Error {
        case failedToFetch
        case failedToUpload
    }
    
    public func updateUserProfile(fullName: String, bio: String, userName: String, websiteLink: String, aboutMe: String, completion: @escaping (Bool) -> Void) {
        let updatedElement = [
            UserProfileKeys.userName.rawValue : userName,
            UserProfileKeys.fullName.rawValue : fullName,
            UserProfileKeys.bio.rawValue : bio,
            UserProfileKeys.websiteLink.rawValue : websiteLink,
            UserProfileKeys.aboutMe.rawValue : aboutMe
        ]
        let update = ["\(userEmail.safeDatabaseKey())/" : updatedElement]
        self.database.updateChildValues(update) { error, _ in
            completion(error == nil)
        }
    }
    
    public func getLoggedInUserProfile(completion: @escaping (Bool , UserProfile?) -> Void) {
        self.getUserProfile(with: userEmail, completion: completion)
    }
    
    public func getUserProfile(with email: String, completion: @escaping (Bool , UserProfile?) -> Void) {
            self.database.child("\(email.safeDatabaseKey())/").observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? [String : Any] {
                    completion(true, UserProfile.userProfileWith(data: value))
            }
            else {
                completion(false, nil)
            }
        }
    }
    
    public typealias UploadPostCompletion = (Result<Bool, Error>) -> Void
    
    public func uploadPost(post: Post, media: [String], completion: @escaping UploadPostCompletion) {
        let post = [
            PostKeys.usersTagged.rawValue : post.usersTagged,
            PostKeys.media.rawValue : media,
            PostKeys.likedUsers.rawValue : post.likedUsers,
//            PostKeys.comments.rawValue : post.comments,
            PostKeys.caption.rawValue : post.caption,
            PostKeys.time.rawValue : post.time
        ] as [String : Any]
        
        self.database.child(loggedInUserPostsPath).observeSingleEvent(of: .value) { snapshot in
            if var collection = snapshot.value as? [[String: Any]] {
                collection.append(post)
                self.uploadPostWithCollection(collection: collection) { success in
                    if success {
                        completion(.success(true))
                    }
                    else {
                        completion(.failure(DatabaseErrors.failedToUpload))
                    }
                }
            } else {
                let newCollection: [[String: Any]] = [post]
                self.uploadPostWithCollection(collection: newCollection) { success in
                    if success {
                        completion(.success(true))
                    }
                    else {
                        completion(.failure(DatabaseErrors.failedToUpload))
                    }
                }
            }
        }
    }
    
    private func uploadPostWithCollection(collection: [[String: Any]], completion: @escaping (Bool) -> Void) {
        self.database.child(loggedInUserPostsPath).setValue(collection) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func getUserPosts(email: String, completion: @escaping ([Post]) -> Void) {
            self.database.child(postsPath(email: email)).observeSingleEvent(of: .value) { snapshot in
            if let collection = snapshot.value as? [[String: Any]] {
                var posts = [Post]()
                for item in collection {
                    posts.append(Post.postDataWith(data: item))
                }
                completion(posts)
            } else {
                completion([Post]())
            }
        }
    }
    
    private func postsPath(email: String) -> String {
        return "user_posts/\(email.safeDatabaseKey())"
    }
    
}

var userEmail: String {
    return UserDefaults.standard.value(forKey: UserProfileKeys.email.rawValue) as? String ?? ""
}

var profilePicsPath: String {
    return "profile_pics/\(userEmail.safeDatabaseKey()).jpg"
}

enum UserProfileKeys: String {
    case email = "email"
    case userName = "user_name"
    case fullName = "full_name"
    case bio = "bio"
    case websiteLink = "website_link"
    case aboutMe = "about_me"
    case profilePic = "profile_pic"
}

enum PostKeys: String {
    case usersTagged = "usersTagged"
    case media = "media"
    case likedUsers = "likedUsers"
    case comments = "comments"
    case caption = "caption"
    case time = "time"
}

var loggedInUserPostsPath: String {
    return "user_posts/\(userEmail.safeDatabaseKey())"
}

var userMediaPath: String {
    return "user_posts/\(userEmail.safeDatabaseKey())/"
}
