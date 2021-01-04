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

final class NetworkClient: NetworkClientProtocol {
    func sendRequest<Response>(request: Request<Response>, completion: @escaping (Result<Decodable, Error>) -> Void) where Response: Decodable {
        guard let url = URL(string: Globals.domain) else {
            fatalError("baseURL could not be configured.")
        }
    
        let urlPath = url.appendingPathComponent(request.path)
        print(urlPath.absoluteString)
        var urlRequest = URLRequest(url: urlPath,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: 15.0)
        urlRequest.httpMethod = request.httpMethod.rawValue

        switch request.type {
        case .default(let values):
            if !values.isEmpty {
                values.forEach { key, value in
                    urlRequest.setValue(key, forHTTPHeaderField: value)
                }
            } else {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        case let .urlParameters(parameters, values):
            guard var urlComponents = URLComponents(url: urlPath, resolvingAgainstBaseURL: false),
                     !parameters.isEmpty else {
                completion(.failure(NetworkErrors.default))
                return
            }

            var queryItems: [URLQueryItem] = []
            parameters.forEach { key, value in
                let queryItem = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                queryItems.append(queryItem)
            }
            urlComponents.queryItems = queryItems

            urlRequest.url = urlComponents.url

            if !values.isEmpty {
                values.forEach { key, value in
                    urlRequest.setValue(key, forHTTPHeaderField: value)
                }
            } else if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
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
        default:
            // TODO other cases
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let response = response {
                    print(response)
                }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data {
                    self.decodeData(request: request, data: data, completion: completion)
                } else {
                    completion(.success("Request without response"))
                }
            }
        }.resume()
    }

    func decodeData<Response>(request: Request<Response>,
                              data: Data,
                              completion: @escaping (Result<Decodable, Error>) -> Void) {
        // print(String(decoding: data, as: UTF8.self))
        guard let decode = try? JSONDecoder().decode(Response.self, from: data) else {
            completion(.failure(NetworkErrors.default))
            return
        }
        completion(.success(decode))
    }
}

