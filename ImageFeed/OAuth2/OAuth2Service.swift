import Foundation
import SwiftKeychainWrapper

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private var lastCode: String?
    
    private (set) var authToken: String? {
        get {
            return KeychainWrapper.standard.string(forKey: Constants.KeychainKeys.authToken)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: Constants.KeychainKeys.authToken)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Constants.KeychainKeys.authToken)
            }
        }
    }

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            completion(.failure(NetworkError.requestInProgress))
            return
        }
        
        lastCode = code
        currentTask?.cancel()
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            lastCode = nil
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.lastCode = nil
                
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.currentTask = task
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        else {
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

    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}

// MARK: - Network Client

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
