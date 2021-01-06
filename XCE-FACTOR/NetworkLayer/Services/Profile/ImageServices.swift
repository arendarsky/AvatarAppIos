//
//  ImageServices.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import Foundation

/// Протокол сервиса для получения и отправки фотографии пользователя
protocol ImageServicesProtocol {
    
    typealias Completion = (Result<Data, NetworkErrors>) -> Void
    
    /// Получить картинку профиля
    func getImage(for name: String, completion: @escaping Completion)
}

/// Сервис для получения и отправки фотографии пользователя
final class ImageServices: ImageServicesProtocol {

    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let basePath: String
    
    private struct Path {
        static let getImage = "photo/get"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case imageName = "name"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func getImage(for name: String, completion: @escaping Completion) {
        let values = [Globals.user.token: "Authorization"]
        let imageNamePath = "/" + ("\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        let request = Request<Data>(path: basePath + "/" + Path.getImage + imageNamePath,
                                    type: .default(values: values),
                                    httpMethod: .post)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let imageData = response as? Data else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(imageData))
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
