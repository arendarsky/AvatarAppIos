//
//  FinalRouter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

/// Протокол роутера экрана Финала
protocol FinalRouterProtocol {
    /// Показать алерт
    /// - Parameter error: Ошибка
    func showError(_ error: Error)

    /// Перейти в экран Профиля
    /// - Parameter userProfile: Модель профиля пользователя
    func routeToProfile(for finalist: UserProfile, profileImage: UIImage?)
}

/// Роутер экрана Финала
final class FinalRouter {

    /// VC для роутинга
    weak var viewController: UIViewController?
}

// MARK: - FinalRouterProtocol

extension FinalRouter: FinalRouterProtocol {
    func showError(_ error: Error) {}

    func routeToProfile(for finalist: UserProfile, profileImage: UIImage?) {
        guard let profileVC = UIStoryboard(name: "Main",
                                           bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController,
            let navigationController = viewController?.navigationController else { return }
        
        profileVC.userData = finalist
        profileVC.isPublic = true
        profileVC.cachedProfileImage = profileImage
        
        navigationController.pushViewController(profileVC, animated: true)
    }
}
