//
//  DescriptionService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

/// Протокол сервиса для установки нового описания профиля пользователя
protocol DescriptionServiceProtocol {
    
    typealias Completion = (ResultDefault) -> Void
    
    /// Установить новое описание профиля
    func set(description: String, completion: @escaping Completion)
}

/// Сервис для установки нового описания профиля пользователя
final class DescriptionService: DescriptionServiceProtocol {

    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let basePath: String
    
    private struct Path {
        static let setDescription = "set_description"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case description
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func set(description: String, completion: @escaping Completion) {
        let parameters = [ParametersKeys.description.rawValue: description]
        let values = [Globals.user.token: "Authorization"]
        let request = Request<String>(path: basePath + "/" + Path.setDescription,
                                      type: .urlParameters(parameters, values: values),
                                      httpMethod: .post)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard response is String else {
                    completion(.failure(.default))
                    return
                }
                completion(.success)
            case .failure(let error):
                guard let error = error as? NetworkErrors else {
                    completion(.failure(.default))
                    return
                }
                completion(.failure(error))
            }
        }
    }
}
