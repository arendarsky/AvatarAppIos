//
//  ProfileServicesManager.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 31.12.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

// TODO: Подумать над оберткой UIImage, здесь не место UIKit
import UIKit

/// Протокол менеджера, отвечающего за  взаимодействие с сервисами профиля
protocol ProfileServicesManagerProtocol {

    typealias Complition = (ResultDefault) -> Void

    func getUserData(for id: Int?, completion: @escaping (Result<UserProfile, NetworkErrors>) -> Void)

    func getNotifications(number: Int, skip: Int, completion: @escaping (Result<[Notification], NetworkErrors>) -> Void)

    func getImage(for name: String, completion: @escaping (Result<UIImage?, NetworkErrors>) -> Void)

    func set(description: String, completion: @escaping Complition)

    func set(name: String, completion: @escaping Complition)
}

/// Менеджер отвечает за сборку (TODO: Assembly) и взаимодействие с сервисами профиля.
final class ProfileServicesManager {

    // MARK: - Private Properties

    private let userProfileService: UserProfileServiceProtocol
    private let notificationsService: NotificationsServiceProtocol
    private let descriptionServices: DescriptionServiceProtocol
    private let imageServices: ImageServicesProtocol
    private let passwordService: PasswordServiceProtocol
    private let nameService: NameServiceProtocol

    private struct Path {
        static let basePath = "/api/profile"
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol) {
        userProfileService = UserProfileService(networkClient: networkClient, basePath: Path.basePath)
        notificationsService = NotificationService(networkClient: networkClient, basePath: Path.basePath)
        descriptionServices = DescriptionService(networkClient: networkClient, basePath: Path.basePath)
        imageServices = ImageServices(networkClient: networkClient, basePath: Path.basePath)
        passwordService = PasswordService(networkClient: networkClient, basePath: Path.basePath)
        nameService = NameService(networkClient: networkClient, basePath: Path.basePath)
    }
}

// MARK: - ProfileManagerProtocol

extension ProfileServicesManager: ProfileServicesManagerProtocol {

    func getUserData(for id: Int?, completion: @escaping (Result<UserProfile, NetworkErrors>) -> Void) {
         if let id = id {
            userProfileService.getUserPublicProfile(id: id, completion: completion)
         } else {
            userProfileService.getUserPrivateProfile(completion: completion)
        }
    }

    func getNotifications(number: Int, skip: Int, completion: @escaping (Result<[Notification], NetworkErrors>) -> Void) {
        notificationsService.getNotifications(number: number, skip: skip, completion: completion)
    }

    func set(description: String, completion: @escaping Complition) {
        descriptionServices.set(description: description, completion: completion)
    }

    func set(name: String, completion: @escaping Complition) {
        nameService.set(name: name, completion: completion)
    }

    func updateUserData(requestModel: ProfileRequestModel, completion: @escaping (ResultDefault) -> Void) {
        userProfileService.updateUserData(requestModel: requestModel) { result in
            switch result {
            case .success(let response):
                completion(response == NetworkClient.noResponseMessage ? .success : .failure(NetworkErrors.default))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func changePassword(from oldPassword: String,
                        to newPassword: String,
                        completion: @escaping (Result<Bool, NetworkErrors>) -> Void) {
        passwordService.changePassword(from: oldPassword, to: newPassword, completion: completion)
    }

    // TODO: Подумать над оберткой UIImage
    func getImage(for name: String, completion: @escaping (Result<UIImage?, NetworkErrors>) -> Void) {
        imageServices.getImage(for: name) { result in
            switch result {
            case .success(let imageData):
                let image = UIImage(data: imageData)
                return completion(.success(image))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
}
