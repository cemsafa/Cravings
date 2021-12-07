//
//  AuthManager.swift
//  Cravings
//
//  Created by Cem Safa on 2021-11-15.
//

import FirebaseAuth

public class AuthManager {
    
    static let shared = AuthManager()
    
    public func loginUser(email: String?, password: String, completion: @escaping (Bool, Error?) -> Void) {
        if let email = email {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                guard authResult != nil, error == nil else {
                    completion(false, error)
                    return
                }
                completion(true, nil)
            }
        }
    }
    
    public func sendPasswordReset(withEmail email: String, _ callback: ((Error?) -> ())? = nil) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            callback?(error)
        }
    }
    
    public func logOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        } catch {
            print(error)
            completion(false)
            return
        }
    }
}
