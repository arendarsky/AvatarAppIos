//
//  NotificationsService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 04.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

/// Протокол сервиса для получения данных по уведомлениям пользователя
protocol NotificationsServiceProtocol {
    
    typealias Completion = (Result<[Notification], NetworkErrors>) -> Void
    
    /// Получить данные пользоваетля
    /// - Parameters:
    ///   - number: <#number description#>
    ///   - skip: <#skip description#>
    ///   - completion: Комплишн завершения запроса
    func getNotifications(number: Int, skip: Int, completion: @escaping Completion)
}

/// Сервис для получения данных по уведомлениям пользователя
final class NotificationService: NotificationsServiceProtocol {

    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let basePath: String
    
    private struct Path {
        static let notifications = "notifications"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case number
        case skip
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func getNotifications(number: Int, skip: Int, completion: @escaping Completion) {
        let parameters = [ParametersKeys.number.rawValue: "\(number)",
                          ParametersKeys.skip.rawValue: "\(skip)"]
        let headers = ["Authorization": Globals.user.token]
        let request = Request<[Notification]>(path: basePath + "/" + Path.notifications,
                                              type: .urlParameters(parameters, encodeType: .urlQueryAllowed),
                                              headers: headers)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard let notifications = response as? [Notification] else {
                    completion(.failure(.default))
                    return
                }
                completion(.success(notifications))
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
