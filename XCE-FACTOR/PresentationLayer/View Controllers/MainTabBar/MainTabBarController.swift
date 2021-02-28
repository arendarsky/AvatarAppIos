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

        let semifinalVC = UINavigationController(rootViewController: QualifyingAssembly.build())
        semifinalVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "bolt.fill"), tag: 2)

        let ratingVC = UINavigationController(rootViewController: RatingAssembly.build())
        ratingVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "star.fill"), tag: 3)

        if viewControllers?.count == 3 {
            viewControllers?.insert(semifinalVC, at: 2)
            viewControllers?.insert(ratingVC, at: 3)
        }

        viewControllers?.forEach { vc in
            vc.tabBarItem.title = nil
        }
    }
}
