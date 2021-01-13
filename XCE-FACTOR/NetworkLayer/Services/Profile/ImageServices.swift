//
//  ImageServices.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import Foundation
import Alamofire

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
        static let uploadImage = "photo/upload"
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
        let headers = ["Authorization": Globals.user.token]
        let request = Request<Data>(path: basePath + "/" + Path.getImage,
                                    type: .image(imagePath: name, encodeType: .urlQueryAllowed),
                                    headers: headers)
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

    func setImage(_ imageData: Data, completion: @escaping (ResultDefault) -> Void) {
//        let headers = [Globals.user.token: "Authorization"]
//        let request = Request<Data>(path: basePath + "/" + Path.uploadImage,
//                                    type: .default,
//                                    httpMethod: .post,
//                                    headers: headers)
        // TODO: Реализовать сервис по загрузке картинки
    }
}
