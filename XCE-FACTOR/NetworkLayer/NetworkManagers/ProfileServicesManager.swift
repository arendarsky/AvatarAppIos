//
//  ProfileServicesManager.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 31.12.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

/// Протокол менеджера, отвечающего за ...
protocol ProfileServicesManagerProtocol {

    func getUserData(for id: Int?, completion: @escaping (Result<UserProfile, NetworkErrors>) -> Void)

    func getNotifications(number: Int, skip: Int, completion: @escaping (Result<[Notification], NetworkErrors>) -> Void)
}

/// Менеджер отвечает за ...
final class ProfileServicesManager {

    // MARK: - Private Properties

    private let userProfileService: UserProfileServiceProtocol
    private let notificationsService: NotificationsServiceProtocol

    private struct Path {
        static let basePath = "/api/profile"
    }

    enum ResultDefault {
        case success
        case failure(_ error: NetworkErrors)
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol) {
        userProfileService = UserProfileService(networkClient: networkClient, basePath: Path.basePath)
        notificationsService = NotificationsService(networkClient: networkClient, basePath: Path.basePath)
    }
}

// MARK: - ProfileManagerProtocol

extension ProfileServicesManager: ProfileServicesManagerProtocol {

    func getUserData(for id: Int?, completion: @escaping (Result<UserProfile, NetworkErrors>) -> Void) {
        userProfileService.getUserData(id: id, completion: completion)
    }

    func getNotifications(number: Int, skip: Int, completion: @escaping (Result<[Notification], NetworkErrors>) -> Void) {
        notificationsService.getNotifications(number: number, skip: skip, completion: completion)
    }
}
