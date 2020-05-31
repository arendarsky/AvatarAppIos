//
//  MainTabBarController.swift
//  XCE-FACTOR
//
//  Created by Владислав on 31.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if Globals.isNewLike {
//            Globals.notificationsTabBarItem?.badgeValue = "♥"
//        }
    }
    
    func configure() {
        self.selectedIndex = 1
        
        if let navVC = viewControllers?.first as? UINavigationController {
            Globals.notificationsTabBarItem = navVC.tabBarItem
            Globals.notificationsTabBarItem?.badgeColor = .systemRed
//            Globals.notificationsTabBarItem?.badgeValue = "♥"
        }

//        if let vc = navVC.viewControllers.first as? NotificationsVC {
//            print("selected")
//            vc.tabBarItem.badgeValue = "1"
//            vc.tabBarItem.badgeColor = .red
//        } else {
//            print(String(describing: type(of: navVC.viewControllers.first)))
//        }
    }
    
}
