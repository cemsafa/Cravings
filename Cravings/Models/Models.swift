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
