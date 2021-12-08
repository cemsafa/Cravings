//
//  Models.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import Foundation
import MessageKit

public struct User {
    let email: String
    let username: String
    let fullname: String
    var profilePictureFilename: String {
        return "\(email.safeDatabaseKey())_profile_picture.png"
    }
}

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

public struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

public struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

public struct Media: MediaItem {
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize
}

public struct SearchResult {
    public let name: String
    public let email: String
}

public struct Post {
    public var usersTagged: [String] = [String]()
    public var media: [String]
    public var likedUsers: [String] = [String]()
//    public var comments: [String] = [String]()
    public var caption: String = ""
    public var time: Double
    
    static func postDataWith(data: [String : Any]) -> Post {
        guard let mediaUrls = data[PostKeys.media.rawValue] as? [String], let time = data[PostKeys.time.rawValue] as? Double else {
            return Post(media: [String](), time: 0)
        }
        var post = Post(media: mediaUrls, time: time)
        post.caption = data[PostKeys.caption.rawValue] as? String ?? ""
        post.likedUsers = data[PostKeys.likedUsers.rawValue] as? [String] ?? [String]()
        post.usersTagged = data[PostKeys.usersTagged.rawValue] as? [String] ?? [String]()
        return post
    }
    
}

public struct UserProfile {
    var userName: String
    var fullName: String
    var websiteLink: String = ""
    var aboutMe: String = ""
    var bio: String = ""
    
    static func userProfileWith(data: [String : Any]) -> UserProfile {
        guard let fullName = data[UserProfileKeys.fullName.rawValue] as? String, let userName = data[UserProfileKeys.userName.rawValue] as? String else {
            return UserProfile.init(userName: "", fullName: "")
        }
        var userProfile = UserProfile.init(userName: userName, fullName: fullName)
        userProfile.websiteLink = data[UserProfileKeys.websiteLink.rawValue] as? String ?? ""
        userProfile.bio = data[UserProfileKeys.bio.rawValue] as? String ?? ""
        userProfile.aboutMe = data[UserProfileKeys.aboutMe.rawValue] as? String ?? ""
        return userProfile
    }
}

public struct PostMedia {
    public let mediaType: MediaType
    public let data: Data
}

public enum MediaType {
    case photo
    case video
}
