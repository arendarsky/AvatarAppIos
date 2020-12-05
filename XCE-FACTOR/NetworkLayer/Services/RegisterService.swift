//
//  RegisterService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 22.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

protocol RegistrationServiceProtocol {
    
    typealias Complition = (Result<Bool, NetworkErrors>) -> Void

    func registerNewUser(requestModel: UserAuthModel, completion: @escaping Complition)
}

final class RegistrationService: RegistrationServiceProtocol {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let authorization = "register"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case name
        case email
        case password
        case isConsentReceived
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func registerNewUser(requestModel: UserAuthModel, completion: @escaping Complition) {
        let name = requestModel.name
        let email = requestModel.email
        let password = requestModel.password
        let isConsentReceived = requestModel.isConsentReceived
        let parameters: [String: Any] = [ParametersKeys.name.rawValue: name,
                                         ParametersKeys.email.rawValue: email,
                                         ParametersKeys.password.rawValue: password,
                                         ParametersKeys.isConsentReceived.rawValue: isConsentReceived]
        
        let request = Request<Bool>(path: basePath + "/" + Path.authorization,
                                    type: .bodyParameters(parameters))
        
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
