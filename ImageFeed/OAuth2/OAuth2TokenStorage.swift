//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//

import Foundation
import WebKit

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "bearerToken"
    
    var token: String? {
            get { UserDefaults.standard.string(forKey: tokenKey) }
            set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
        }
}
