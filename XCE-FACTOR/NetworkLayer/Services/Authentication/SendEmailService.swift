//
//  SendEmailService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 23.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

protocol SendEmailServiceProtocol {
    
    typealias Complition = (SendEmailService.Result) -> Void
    
    /// Отправить сообщение с подтвержением на указанный email
    /// - Parameters:
    ///   - email: Email пользователя
    ///   - completion: Комплишн блок
    func send(email: String, completion: @escaping Complition)
}

final class SendEmailService: SendEmailServiceProtocol {

    // MARK: - Private Properties

    private let networkClient: NetworkClientProtocol
    private let basePath: String

    private struct Path {
        static let sendEmail = "send"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case email
    }

    enum Result {
        case success
        case failure(_ error: NetworkErrors)
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func send(email: String, completion: @escaping Complition) {
        let parameters = [ParametersKeys.email.rawValue: email]
        // TODO: Нужно протестить работу возвращаемой модели!
        let request = Request<String>(path: basePath + "/" + Path.sendEmail,
                                      type: .urlParameters(parameters))
        
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success:
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
