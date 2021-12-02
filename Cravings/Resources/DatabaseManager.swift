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

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    public func canCreateUser(with email: String, completion: @escaping (Bool) -> Void) {
        database.child(email.safeDatabaseKey()).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
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
                    self.database.child("\(otherUserEmail.safeDatabaseKey())/conversations").setValue([conversationId])
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
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
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
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    var targetConversation: [String: Any]?
                    var position = 0
                    for conversationDict in currentUserConversations {
                        if let currentId = conversationDict["id"] as? String, currentId == conversation {
                            targetConversation = conversationDict
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConversation
                    self.database.child("\(currentEmail)").setValue(currentUserConversations) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        self.database.child("\(otherUserEmail.safeDatabaseKey())/conversations").observeSingleEvent(of: .value) { snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var targetConversation: [String: Any]?
                            var position = 0
                            for conversationDict in otherUserConversations {
                                if let currentId = conversationDict["id"] as? String, currentId == conversation {
                                    targetConversation = conversationDict
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConversation
                            self.database.child("\(otherUserEmail.safeDatabaseKey())").setValue(otherUserConversations) { error, _ in
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
    
    public enum DatabaseErrors: Error {
        case failedToFetch
    }
    
    
    
    
    public func updateUserProfile(fullName: String, bio: String, userName: String, websiteLink: String, aboutMe: String, completion: @escaping (Bool) -> Void) {
        let updateElement = [
            UserProfileKeys.userName.rawValue : userName,
            UserProfileKeys.fullName.rawValue : fullName,
            UserProfileKeys.bio.rawValue : bio,
            UserProfileKeys.websiteLink.rawValue : websiteLink,
            UserProfileKeys.aboutMe.rawValue : aboutMe
        ]
        self.database.child("users").observeSingleEvent(of: .value) { snapshot in
            let collection = snapshot.value as? [String: [String : String]] ?? [String: [String : String]]()
            if let key = collection.first(where: { $0.value[UserProfileKeys.email.rawValue] == userEmail })?.key {
                self.database.child("users").child(key).setValue(updateElement) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func updateUserProfilePicture(profilePic: UIImage, completion: @escaping (Bool) -> Void) {
        let updateElement = [
            UserProfileKeys.profilePic.rawValue : ""
        ]
        self.database.child("users").observeSingleEvent(of: .value) { snapshot in
            let collection = snapshot.value as? [String: [String : String]] ?? [String: [String : String]]()
            if let key = collection.first(where: { $0.value[UserProfileKeys.email.rawValue] == userEmail })?.key {
                self.database.child("users").child(key).setValue(updateElement) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
//    func uploadProfilePic(completion: @escaping (_ url: String?) -> Void) {
//        let storageRef = FirebaseStorage.StorageReference.reference().child("myImage.png")
////        if let uploadData = UIImagePNGRepresentation(self.myImageView.image!) {
////            storageRef.put(uploadData, metadata: nil) { (metadata, error) in
////                if error != nil {
////                    print("error")
////                    completion(nil)
////                } else {
////                    completion((metadata?.downloadURL()?.absoluteString)!))
////                    // your uploaded photo url.
////                }
////           }
//     }
    
    public func getUserProfile(completion: @escaping (Bool , [String : String]?) -> Void) {
        self.database.child("users").observeSingleEvent(of: .value) { snapshot in
            let collection = snapshot.value as? [[String : String]] ?? [[String : String]]()
            if let value = collection.first(where: { $0[UserProfileKeys.email.rawValue] == userEmail }) {
                completion(true, value)
            }
            else {
                completion(false, nil)
            }
        }
    }
    
}

let userEmail: String = UserDefaults.standard.value(forKey: "email") as? String ?? ""

public struct User {
    let email: String
    let username: String
    let fullname: String
    var profilePictureFilename: String {
        return "\(email.safeDatabaseKey())_profile_picture.png"
    }
}


enum UserProfileKeys: String {
    case email = "email"
    case userName = "username"
    case fullName = "name"
    case bio = "bio"
    case websiteLink = "website_link"
    case aboutMe = "about_me"
    case profilePic = "profile_pic"
}
