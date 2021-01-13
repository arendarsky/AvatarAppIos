//
//  PasswordService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 07.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

/// Протокол сервиса для получения и отправки фотографии пользователя
protocol PasswordServiceProtocol {
    
    typealias Completion = (Result<Bool, NetworkErrors>) -> Void
    
    /// Сменить пароль пользователя
    func changePassword(from oldPassword: String, to newPassword: String, completion: @escaping Completion)
}

/// Сервис для смены пароля пользователя
final class PasswordService: PasswordServiceProtocol {

    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let basePath: String
    
    private struct Path {
        static let password = "set_password"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case oldPassword
        case newPassword
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func changePassword(from oldPassword: String, to newPassword: String, completion: @escaping Completion) {
        let headers = ["Authorization": Globals.user.token]
        let parameters = [ParametersKeys.oldPassword.rawValue: oldPassword,
                          ParametersKeys.newPassword.rawValue: newPassword]
        let request = Request<Bool>(path: basePath + "/" + Path.password,
                                    type: .urlParameters(parameters, encodeType: .urlQueryAllowed),
                                    httpMethod: .post,
                                    headers: headers)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let isCorrect = response as? Bool else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(isCorrect))
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
