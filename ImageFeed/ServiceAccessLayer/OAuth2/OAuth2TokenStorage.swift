//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let dataStorage =  UserDefaults.standard
    
    private let tokenKey = "bearerToken"
    
    var token: String? {
        get {
            dataStorage.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                dataStorage.set(token, forKey: tokenKey)
            } else {
                dataStorage.removeObject(forKey: tokenKey)
            }
        }
    }
}
