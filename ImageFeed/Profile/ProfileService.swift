//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 18.06.2025.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
    case requestInProgress
}

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            completion(.failure(ProfileServiceError.requestInProgress))
            return
        }
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                
                switch result {
                case .success(let profileResult):
                    let profile = Profile(from: profileResult)
                    self?.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

struct ProfileResult: Codable {
    let id: String
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

extension Profile {
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = "\(profileResult.firstName) \(profileResult.lastName ?? "")"
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
    
    var isValid: Bool {
        !username.isEmpty && !name.isEmpty
    }
}
