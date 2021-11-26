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
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    public typealias DownloadPictureCompletion = (Result<URL, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(filename)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(filename)").downloadURL { url, error in
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
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}
