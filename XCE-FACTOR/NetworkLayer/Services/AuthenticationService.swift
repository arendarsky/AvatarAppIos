//
//  AuthenticationService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 22.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

protocol AuthenticationServiceProtocol {
    
    typealias Complition = (Result<Decodable, NetworkErrors>) -> Void

    func startAuthorization(requestModel: Credentials, completion: @escaping Complition)
}

final class AuthenticationService: AuthenticationServiceProtocol {
    
    private let networkClient: NetworkClientProtocol
    
    private struct Path {
        static let authorization = "/api/auth/authorize"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case email
        case password
    }

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func startAuthorization(requestModel: Credentials, completion: @escaping Complition) {
        let email = requestModel.email
        let password = requestModel.password
        let parameters = [ParametersKeys.email.rawValue: email,
                          ParametersKeys.password.rawValue: password]
        let request = Request<TokenModel>(path: Path.authorization,
                                          type: .urlParameters(parameters),
                                          httpMethod: .post)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let tokenModel = response as? TokenModel else {
                    completion(.failure(.default))
                    return
                }
                // Обработать это логику в authorizationManager:
                // start
                guard !tokenModel.confirmationRequired else {
                    print("Error: User email is not confirmed")
                    completion(.failure(NetworkErrors.unconfirmed))
                    return
                }
                
                guard let token = tokenModel.token else {
                    print("Wrong email or password")
                    completion(.failure(NetworkErrors.wrondCredentials))
                    return
                }

                print("   success with token \(token)")
                /// Saving to Globals and Defaults
                Globals.user.token = "Bearer \(token)"
                Globals.user.email = email
                Defaults.save(token: Globals.user.token, email: Globals.user.email)
                // end
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
