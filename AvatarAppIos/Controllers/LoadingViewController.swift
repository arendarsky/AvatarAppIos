//
//  LoadingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        checkToken()
    }
    
    func checkToken() {
//        if user.isFirstAppStart {
//            Defaults.save(token: "", email: "")
//            user.isFirstAppStart = false
//        }
//
        let userDetails = Defaults.getData()
        print(userDetails)
        if userDetails.token != "" {
            //presentNewRootViewController(animated: false)
            user.email = userDetails.email
            user.token = userDetails.token
            //MARK:- Fetch Profile Data
            Profile.getData(id: nil) { (serverResult) in
                switch serverResult {
                case.error(let error):
                    print("Error: \(error)")
                case.results(let userData):
                    user.videosCount = userData.videos?.count
                    let vc = self.storyboard?.instantiateViewController(identifier: "MainTabBarController")
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            }
        } else {
            let vc = self.storyboard?.instantiateViewController(identifier: "WelcomeScreenNavBar")
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }

}
