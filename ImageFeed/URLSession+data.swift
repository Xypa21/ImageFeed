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
    case invalidResponseError
    case noData
    case requestInProgress
}


extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            switch result {
            case .failure(let error):
                print("[dataTask]: \(error.localizedDescription) - URL: \(request.url?.absoluteString ?? "")")
            default:
                break
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let error = NetworkError.httpStatusCode(statusCode)
                    print("[dataTask]: NetworkError - код ошибки \(statusCode), URL: \(request.url?.absoluteString ?? "")")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            } else if let error = error {
                print("[dataTask]: URLRequestError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                let error = NetworkError.urlSessionError
                print("[dataTask]: URLSessionError - неизвестная ошибка сессии, URL: \(request.url?.absoluteString ?? "")")
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        })
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let dataString = String(data: data, encoding: .utf8) ?? "нечитаемые данные"
                    print("[objectTask]: DecodingError - \(error.localizedDescription), Data: \(dataString)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
