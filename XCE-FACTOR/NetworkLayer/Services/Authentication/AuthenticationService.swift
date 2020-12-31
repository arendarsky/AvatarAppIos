//
//  AuthenticationService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 22.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

protocol AuthenticationServiceProtocol {
    
    typealias Completion = (Result<TokenModel, NetworkErrors>) -> Void

    func startAuthorization(requestModel: Credentials, completion: @escaping Completion)
}

final class AuthenticationService: AuthenticationServiceProtocol {

    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let basePath: String
    
    private struct Path {
        static let authorization = "authorize"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case email
        case password
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func startAuthorization(requestModel: Credentials, completion: @escaping Completion) {
        let email = requestModel.email
        let password = requestModel.password
        let parameters = [ParametersKeys.email.rawValue: email,
                          ParametersKeys.password.rawValue: password]
        let request = Request<TokenModel>(path: basePath + "/" + Path.authorization,
                                          type: .urlParameters(parameters),
                                          httpMethod: .post)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let tokenModel = response as? TokenModel else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(tokenModel))
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
