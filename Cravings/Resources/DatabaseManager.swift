//
//  DatabaseManager.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import Firebase

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Firestore.firestore()
    
    private var ref: DocumentReference? = nil
    
    public func canCreateNewUser(with email: String, username: String, completion: (Bool) -> Void) {
        completion(true)
    }
    
    public func insertNewUser(with email: String, username: String, fullname: String, completion: @escaping (Bool) -> Void) {
        ref = database.collection("users").addDocument(data: [
            "email": email.safeDatabaseKey(),
            "username": username,
            "fullname": fullname
        ]) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
                completion(false)
                return
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
                completion(true)
                return
            }
        }
    }
}

// MARK: - Extension for String
extension String {
    func safeDatabaseKey() -> String {
        return replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    }
}
