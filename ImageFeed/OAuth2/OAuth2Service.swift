//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//

import Foundation


final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
    
    private enum OAuth2ServiceError: Error {
            case invalidRequest
            case invalidResponse
            case duplicateRequest
        }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        else {
            print("[OAuth2Service] Failed to create base URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        if lastCode == code { 
            print("[OAuth2Service] Duplicate request detected")
            completion(.failure(OAuth2ServiceError.duplicateRequest))
            return }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service] Failed to create request")
            completion(.failure(OAuth2ServiceError.invalidRequest))
            return }
        
        
        task = URLSession.shared.data(for: request) { [weak self] result in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            do {
                                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                                OAuth2TokenStorage.shared.token = tokenResponse.accessToken
                                print("[OAuth2Service] Successfully received token")
                                guard !tokenResponse.accessToken.isEmpty else {
                                    completion(.failure(OAuth2ServiceError.invalidResponse))
                                    return
                                }
                                completion(.success(tokenResponse.accessToken))
                            } catch {
                                print("[OAuth2Service] Decoding error: \(error.localizedDescription)")
                                completion(.failure(error))
                            }
                        case .failure(let error):
                            print("[OAuth2Service] Network error: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                        
                        self.lastCode = nil
                    }
                }
                
                task?.resume()
            }
        }
