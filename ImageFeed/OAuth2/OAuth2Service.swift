//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case requestInProgress
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let dataStorage = OAuth2TokenStorage()
    private init() { }
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private (set) var authToken: String? {
        get {
            return dataStorage.token
        }
        set {
            dataStorage.token = newValue
        }
    }
    
    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: "https://unsplash.com")!
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code {
                    completion(.failure(AuthServiceError.requestInProgress))
                    return
                }
        
        task?.cancel()
        lastCode = code
        
        UIBlockingProgressHUD.show()
        
        guard let request = makeOAuthTokenRequest(code: code)
        else {
            UIBlockingProgressHUD.dismiss()
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = object(for: request) { [weak self] result in
                    DispatchQueue.main.async {
                        UIBlockingProgressHUD.dismiss()
                        guard self?.lastCode == code else {
                            completion(.failure(AuthServiceError.invalidRequest))
                                                return
                                            }
                        switch result {
                                        case .success(let responseBody):
                                            let authToken = responseBody.accessToken
                                            self?.authToken = authToken
                                            completion(.success(authToken))
                                        case .failure(let error):
                                            completion(.failure(error))
                                        }
                                        
                                        self?.task = nil
                                        self?.lastCode = nil
                                    }
                                }
        self.task = task
        task.resume()
    }
}

extension OAuth2Service {
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body))
                }
                catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

