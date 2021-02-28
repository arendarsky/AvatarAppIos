//
//  NetworkClient.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 22.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

protocol NetworkClientProtocol {
    /// Отправка сетевого запроса
    ///
    /// - Parameters:
    ///   - request: модель запроса
    ///   - completion: комплишн блок
    func sendRequest<Response>(request: Request<Response>,
                               completion: @escaping (Result<Decodable, Error>) -> Void)
}

final class NetworkClient {
    static let noResponseMessage = "Request without response"
}

// MARK: - NetworkClientProtocol

extension NetworkClient: NetworkClientProtocol {

    func sendRequest<Response>(request: Request<Response>, completion: @escaping (Result<Decodable, Error>) -> Void) where Response: Decodable {
        guard let url = URL(string: Globals.domain) else {
            fatalError("baseURL could not be configured.")
        }
    
        let urlPath = url.appendingPathComponent(request.path)
        var urlRequest = URLRequest(url: urlPath,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: 15.0)

        urlRequest.httpMethod = request.httpMethod.rawValue

        if !request.headers.isEmpty {
            request.headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        }

        switch request.type {
        case .default:
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        case let .urlParameters(parameters, encodeType):
            guard var urlComponents = URLComponents(url: urlPath, resolvingAgainstBaseURL: false),
                     !parameters.isEmpty else {
                completion(.failure(NetworkErrors.default))
                return
            }

            var queryItems: [URLQueryItem] = []
            parameters.forEach { key, value in
                let queryItem = URLQueryItem(name: key, value: value.encodeIfNeeded(to: encodeType))
                queryItems.append(queryItem)
            }
            urlComponents.queryItems = queryItems
            urlRequest.url = urlComponents.url
        case .bodyParameter(let parameter):
            guard let body = try? JSONSerialization.data(withJSONObject: parameter, options: [.fragmentsAllowed]) else {
                completion(.failure(NetworkErrors.notAllPartsFound))
                return
            }

            urlRequest.httpBody = body
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        case .bodyParameters(let parameters):
            guard let body = try? JSONSerialization.data(withJSONObject: parameters,
                                                         options: .prettyPrinted) else {
                print("Error encoding user data")
                completion(.failure(NetworkErrors.notAllPartsFound))
                                                            return
            }

            urlRequest.httpBody = body
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        case let .image(imagePath, encodeType):
            let path = urlPath.appendingPathComponent(imagePath.encodeIfNeeded(to: encodeType))
            urlRequest.url = path
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse {
                    if request.checkStatusCode200 && response.statusCode != 200 {
                        completion(.failure(NetworkErrors.default))
                    }
                    print(response)
                }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if case .image = request.type {
                    return completion(.success(data))
                } else if let data = data, !data.isEmpty {
                    self.decodeData(request: request, data: data, completion: completion)
                } else {
                    completion(.success(NetworkClient.noResponseMessage))
                }
            }
        }.resume()
    }
}

// MARK: - Private Methods

private extension NetworkClient {

    func decodeData<Response>(request: Request<Response>,
                              data: Data,
                              completion: @escaping (Result<Decodable, Error>) -> Void) {
        print(String(decoding: data, as: UTF8.self))
        guard let decode = try? JSONDecoder().decode(Response.self, from: data) else {
            completion(.failure(NetworkErrors.default))
            return
        }
        completion(.success(decode))
    }
}

// MARK: - Private String + Extension

private extension String {
    func encodeIfNeeded(to type: CharacterSet?) -> String {
        guard let type = type else { return self }
        return self.addingPercentEncoding(withAllowedCharacters: type) ?? self
    }
}
