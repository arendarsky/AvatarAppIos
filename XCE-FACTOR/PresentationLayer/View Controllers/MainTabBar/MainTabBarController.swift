//
//  MainTabBarController.swift
//  XCE-FACTOR
//
//  Created by Владислав on 31.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }

    // MARK: - Private Methods
    
    private func configureTabBar() {
        selectedIndex = 1 // Экран, который открывается первым

        let semifinalVC = UINavigationController(rootViewController: SemifinalAssembly.build())
        semifinalVC.tabBarItem = UITabBarItem(title: "Полуфинал", image: UIImage(systemName: "bolt.fill"), tag: 2)

        let ratingVC = UINavigationController(rootViewController: RatingAssembly.build())
        ratingVC.tabBarItem = UITabBarItem(title: "Рейтинг", image: UIImage(systemName: "star.fill"), tag: 3)

        if viewControllers?.count == 3 {
            viewControllers?.insert(semifinalVC, at: 2)
            viewControllers?.insert(ratingVC, at: 3)
        }
    }
}
