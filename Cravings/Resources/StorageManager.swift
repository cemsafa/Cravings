//
//  StorageManager.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-24.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    public typealias DownloadPictureCompletion = (Result<URL, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, completion: @escaping UploadPictureCompletion) {
        storage.child(profilePicsPath).putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.getProfilePictureURL { result in
                switch result {
                    case .success(let url):
                        completion(.success(url.absoluteString))
                    case .failure(_):
                        completion(.failure(StorageErrors.failedToUpload))
                }
            }
        }
    }
    
    public func getProfilePictureURL(completion: @escaping DownloadPictureCompletion) {
        self.storage.child(profilePicsPath).downloadURL { url, error in
            guard let url = url else {
                print("Failed to get download url")
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
    public func downloadURL(for path: String, completion: @escaping DownloadPictureCompletion) {
        let ref = storage.child(path)
        ref.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
    public func uploadMessagePhoto(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(filename)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("message_images/\(filename)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public func uploadMessageVideo(with url: URL, filename: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_videos/\(filename)").putFile(from: url, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("message_videos/\(filename)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    private func uploadImageForPost(with data: Data,fileName: String, completion: @escaping UploadMediaCompletion) {
        let path = "\(userMediaPath)\(fileName)"
        let ref = storage.child(path)
        ref.putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            ref.downloadURL { url, error in
                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
    private func uploadVideoForPost(with data: Data, fileName: String, completion: @escaping UploadMediaCompletion) {
        let path = "\(userMediaPath)\(fileName)"
        let ref = storage.child(path)
        ref.putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            ref.downloadURL { url, error in
                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
    private func uploadMediaForPost(with medias: [PostMedia], completion: @escaping UploadAllMediaCompletion) {
        var uploadedURLs = [String]()
        let mediaCount = medias.count
        for (index, media) in medias.enumerated() {
            if media.mediaType == .photo {
                let fileName = "\(timeStamp)_image_\(index).jpg"
                self.uploadImageForPost(with: media.data, fileName: fileName) { result in
                    switch result {
                    case .success(let url):
                        uploadedURLs.append(url)
                        if mediaCount == uploadedURLs.count {
                            completion(.success(uploadedURLs))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                }
            }
            else {
                let fileName = "\(timeStamp)_video_\(index).mp4"
                self.uploadVideoForPost(with: media.data, fileName: fileName) { result in
                    switch result {
                    case .success(let url):
                        uploadedURLs.append(url)
                        if mediaCount == uploadedURLs.count {
                            completion(.success(uploadedURLs))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                }
            }
            
        }
    }
    
    public typealias UploadPostCompletion = (Result<Bool, Error>) -> Void
    public typealias UploadMediaCompletion = (Result<String, Error>) -> Void
    public typealias UploadAllMediaCompletion = (Result<[String], Error>) -> Void
    
    public func addPost(with post: Post,media: [PostMedia] , completion: @escaping UploadPostCompletion) {
        self.uploadMediaForPost(with: media) { result in
            switch result {
            case .success(let uploadedURLs):
                DatabaseManager.shared.uploadPost(post: post, media: uploadedURLs) { result in
                    switch result {
                    case .success(_):
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

public var timeStamp: Double {
    return NSDate().timeIntervalSince1970
}
