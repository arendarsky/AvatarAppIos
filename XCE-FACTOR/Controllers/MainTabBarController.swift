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
        
        if let navC = viewControllers?.first as? UINavigationController {
            Globals.notificationsTabBarItem = navC.tabBarItem
            Globals.notificationsTabBarItem?.badgeColor = .systemRed
//            Globals.notificationsTabBarItem?.badgeValue = "♥"
        }
        
        //to disable any tabbar item:
        //tabBar.items?.first?.isEnabled = false

    }
    
}
