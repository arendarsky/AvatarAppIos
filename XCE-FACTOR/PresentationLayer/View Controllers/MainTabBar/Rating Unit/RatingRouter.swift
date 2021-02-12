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
    
    /// Поделится видео
    /// - Parameter video: Модель видео
    func shareVideo(_ video: Video)
    
    /// Вызов экрана информации
    func showModalInfoScreen(type: InfoViewController.InfoType)
}

/// Роутер экрана Рейтинга
final class RatingRouter {

    // TODO: РАЗГРУЗИТЬ SHARE и заменить RatingViewController на UIViewController
	/// Экран Рэйтинга
	weak var viewController: RatingViewController?
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

    func shareVideo(_ video: Video) {
        guard let vc = viewController else { return }

        // TODO: Разгрузить логику: часть в интерактор, часть в менеджеры алертов и тп..
        let shareImg = IconsManager.getIcon(.shareIcon)?.applyingSymbolConfiguration(.init(pointSize: 24, weight: .regular))
        let buttons = [
            UIAlertAction(title: "Добавить в историю", image: IconsManager.getIcon(.instagramLogo24p), style: .default) { _ in
                vc.prepareAndShareToStories(videoUrl: video.url, enableActivityHandler: {
                    vc.ratingCollectionView.isUserInteractionEnabled = false
                }, disableActivityHandler: {
                    vc.ratingCollectionView.isUserInteractionEnabled = true
                })
            },

            UIAlertAction(title: "Поделиться…", image: shareImg, style: .default) { _ in
                ShareManager.presentShareSheetVC(for: video, delegate: vc)
            }
        ]

        if CacheManager.shared.getLocalIfExists(at: video.url) == nil {
            buttons.first?.isEnabled = false
        }

        vc.showActionSheetWithOptions(title: nil, buttons: buttons)
    }

    func showModalInfoScreen(type: InfoViewController.InfoType) {
        // TODO: Реализовать логику вызова в Info Unit (InfoViewController)
    }
}
