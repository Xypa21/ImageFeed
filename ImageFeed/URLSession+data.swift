//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
    case httpResponseError
    case dataError
}


extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}


extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    do {
                        let decodedObject = try decoder.decode(T.self, from: data)
                        completion(.success(decodedObject))
                    } catch let decodingError {
                        print("[Decoding Error] Type: \(T.self)")
                        print("[Decoding Error] Description: \(decodingError.localizedDescription)")
                        print("[Decoding Error] Raw data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                        
                        completion(.failure(NetworkError.decodingError(decodingError)))
                    }
                    
                case .failure(let error):
                    print("[Network Error] Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
                    print("[Network Error] Description: \(error.localizedDescription)")
                    
                    if let urlError = error as? URLError {
                        print("[Network Error] URL Error Code: \(urlError.errorCode)")
                        print("[Network Error] Failing URL: \(urlError.failingURL?.absoluteString ?? "nil")")
                    }
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}
