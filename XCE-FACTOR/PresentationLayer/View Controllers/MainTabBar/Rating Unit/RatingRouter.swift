//	RatingRouter.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 06.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

/// Протокол роутера экрана Рейтинга
protocol RatingRouterProtocol {
    /// Перейти в экран Профиля
    /// - Parameter userProfile: Модель профиля пользователя
    func routeToProfileVC(for userProfile: UserProfile, profileImage: UIImage?)
    
    /// Вызов экрана информации
    func showModalInfoScreen(type: InfoViewController.InfoType)
}

/// Роутер экрана Рейтинга
final class RatingRouter {

	/// Экран Рэйтинга
	weak var viewController: UIViewController?
}

// MARK: - RatingViewControllerProtocol

extension RatingRouter: RatingRouterProtocol {
    func routeToProfileVC(for userProfile: UserProfile, profileImage: UIImage?) {
        guard let profileVC = UIStoryboard(name: "Main",
                                           bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController,
              let navigationController = viewController?.navigationController else { return }

        profileVC.userData = userProfile
        profileVC.isPublic = true
        profileVC.cachedProfileImage = profileImage
        
        navigationController.pushViewController(profileVC, animated: true)
    }

    func showModalInfoScreen(type: InfoViewController.InfoType) {
        // TODO: Реализовать логику вызова в Info Unit (InfoViewController)
    }
}
