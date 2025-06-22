//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 19.06.2025.
//

import Foundation
import SwiftKeychainWrapper

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeRequest(username: username) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileImage, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let profileImage):
                        self.avatarURL = profileImage.profileImage.large
                        completion(.success(profileImage.profileImage.large))
                        self.notifyObserver()
                    case .failure(let error):
                        print("[ProfileImageService]: ImageError - \(error.localizedDescription), Username: \(username)")
                        completion(.failure(error))
                    }
                }
            }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        if let token = KeychainWrapper.standard.string(forKey: Constants.KeychainKeys.authToken)
        {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func notifyObserver() {
        NotificationCenter.default.post(
            name: Notification.Name(Constants.NotificationNames.profileImageDidChange),
            object: self
        )
    }
}

struct ProfileImage: Codable {
    let profileImage: ProfileImageURLs
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImageURLs: Codable {
    let large: String
}

extension ProfileImageService {
    static var didChangeNotification: Notification.Name {
        return Notification.Name(Constants.NotificationNames.profileImageDidChange)
    }
}
