//
//  StorageManager.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-24.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<Bool, Error>) -> Void
    public typealias DownloadPictureCompletion = (Result<URL, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, completion: @escaping UploadPictureCompletion) {
        storage.child(profilePicsPath).putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            completion(.success(true))
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
}
