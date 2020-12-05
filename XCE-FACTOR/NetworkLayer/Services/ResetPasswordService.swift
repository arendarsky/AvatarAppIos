//
//  ResetPasswordService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 23.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

protocol ResetPasswordServiceProtocol {
    
    typealias Complition = (Result<Bool, NetworkErrors>) -> Void
    
    /// Отправить сообщение с подтвержением на указанный email
    /// - Parameters:
    ///   - email: Email пользователя
    ///   - completion: Комплишн блок
    func resetPassword(email: String, completion: @escaping Complition)
}

final class ResetPasswordService: ResetPasswordServiceProtocol {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let reset = "send_reset"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case email
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func resetPassword(email: String, completion: @escaping Complition) {
        let parameters = [ParametersKeys.email.rawValue: email]
        // TODO: Нужно протестить работу возвращаемой модели!
        let request = Request<Bool>(path: basePath + "/" + Path.reset,
                                    type: .urlParameters(parameters))
        
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let response = response as? Bool else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(response))
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

