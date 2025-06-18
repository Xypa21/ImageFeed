//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 18.06.2025.
//

import Foundation

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    struct ProfileResult: Codable {
        let username: String
        let firstName: String?
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username = "username"
            case firstName = "first_name"
            case lastName = "last_name"
            case bio = "bio"
        }
    }
    
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
        
        init(result: ProfileResult) {
            self.username = result.username
            self.loginName = "@" + result.username
            
            var nameComponents = [String]()
            if let firstName = result.firstName {
                nameComponents.append(firstName)
            }
            if let lastName = result.lastName {
                nameComponents.append(lastName)
            }
            self.name = nameComponents.joined(separator: " ")
            self.bio = result.bio
        }
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profileResult):
                    let profile = Profile(result: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
