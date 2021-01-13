//
//  UserProfileService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 31.12.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

protocol UserProfileServiceProtocol {
    
    typealias Completion = (Result<UserProfile, NetworkErrors>) -> Void
    
    /// Получить данные профиля текущего пользоваетля
    /// - Parameter completion: Комплишн завершения запроса
    func getUserPrivateProfile(completion: @escaping Completion)

    /// Получить данные профиля пользоваетля для просмотра
    /// - Parameters:
    ///   - id: ID уже вошедшего пользователя
    ///   - completion: Комплишн завершения запроса
    func getUserPublicProfile(id: Int, completion: @escaping Completion)
    
    /// Изменить данные профиля пользоваетля
    /// - Parameters:
    ///   - requestModel: Модель запроса
    ///   - completion: Комплишн завершения запроса
    func updateUserData(requestModel: ProfileRequestModel, completion: @escaping (Result<String, NetworkErrors>) -> Void)
}

/// Сервис для получения данных пользователя
final class UserProfileService {

    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let basePath: String
    
    private struct Path {
        static let getPersonalData = "get"
        static let getPublicProfileData  = "public/get"
        static let updateData = "update_profile"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case id
        case name
        case description
        case instagramLogin
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }
}

// MARK: - UserProfileServiceProtocol

extension UserProfileService: UserProfileServiceProtocol {

    func getUserPrivateProfile(completion: @escaping Completion) {
        let header = ["Authorization": Globals.user.token]
        let request = Request<UserProfile>(path: basePath + "/" + Path.getPersonalData,
                                           type: .default,
                                           headers: header)
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

    func getUserPublicProfile(id: Int, completion: @escaping Completion) {
        let header = ["Authorization": Globals.user.token]
        let request = Request<UserProfile>(path: basePath + "/" + Path.getPublicProfileData,
                                           type: .urlParameters([ParametersKeys.id.rawValue: "\(id)"],
                                                                encodeType: .urlQueryAllowed),
                                           headers: header)
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

    func updateUserData(requestModel: ProfileRequestModel,
                        completion: @escaping (Result<String, NetworkErrors>) -> Void) {
        let headers = ["Content-Type": "application/json",
                       "Authorization": Globals.user.token]
        let parameters = [ParametersKeys.name.rawValue: requestModel.name,
                          ParametersKeys.description.rawValue: requestModel.description,
                          ParametersKeys.instagramLogin.rawValue: requestModel.instagramLogin]
        let request = Request<String>(path: basePath + "/" + Path.updateData,
                                      type: .bodyParameters(parameters),
                                      httpMethod: .post,
                                      headers: headers,
                                      checkStatusCode200: true)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let responseString = response as? String else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(responseString))
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
