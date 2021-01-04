//
//  UserProfileService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 31.12.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

protocol UserProfileServiceProtocol {
    
    typealias Completion = (Result<UserProfile, NetworkErrors>) -> Void
    
    /// Получить данные пользоваетля
    /// - Parameters:
    ///   - id: ID уже вошедшего пользователя
    ///   - completion: Комплишн завершения запроса
    func getUserData(id: Int?, completion: @escaping Completion)
}

/// Сервис для получения данных пользователя
final class UserProfileService: UserProfileServiceProtocol {

    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let basePath: String
    
    private struct Path {
        static let getData = "get"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case id
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func getUserData(id: Int?, completion: @escaping Completion) {
        let type = configureType(for: id)
        let request = Request<UserProfile>(path: basePath + "/" + Path.getData, type: type)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let userProfile = response as? UserProfile else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(userProfile))
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

// MARK: - Private Methods

private extension UserProfileService {
    func configureType(for id: Int?) -> HTTPRequestType {
        let value = [Globals.user.token: "Authorization"]
        if let id = id {
            // TODO ID
            return .urlParameters([ParametersKeys.id.rawValue: "\(id)"], values: value)
        } else {
            return .default(values: value)
        }
    }
}
