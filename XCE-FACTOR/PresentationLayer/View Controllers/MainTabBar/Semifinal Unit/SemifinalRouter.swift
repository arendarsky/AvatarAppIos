//	SemifinalRouter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 04.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

/// Протокол роутера, отвечающий за навигацию экрана Полуфинала
protocol SemifinalRouterProtocol {
    /// Перейти в экран Профиля
    /// - Parameter userProfile: Модель профиля пользователя
    func routeToProfileVC(for userProfile: UserProfile)
}

/// Роутер, отвечающий за навигацию экрана Полуфинала
final class SemifinalRouter {

    /// Контроллер Полуфинала
    weak var viewController: UIViewController?
}

// MARK: - SemifinalViewControllerProtocol

extension SemifinalRouter: SemifinalRouterProtocol {
    func routeToProfileVC(for userProfile: UserProfile) {
       guard let profileVC = UIStoryboard(name: "Main",
                                          bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController,
             let navigationController = viewController?.navigationController else { return }

        profileVC.userData = userProfile
        profileVC.isPublic = true

        navigationController.pushViewController(profileVC, animated: true)
    }
}
