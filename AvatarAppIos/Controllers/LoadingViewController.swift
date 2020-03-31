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
        System.clearance()
        checkToken()
    }
    
    func checkToken() {

        let userDetails = Defaults.getData()
        print(userDetails)
        if userDetails.token != "" {
            //presentNewRootViewController(animated: false)
            user.email = userDetails.email
            user.token = userDetails.token
            //MARK:- Fetch Profile Data
            Profile.getData(id: nil) { (serverResult) in
                print(serverResult)
                switch serverResult {
                case.error(let error):
                    print("Error: \(error)")
                    self.setApplicationRootVC(storyboardID: "WelcomeScreenNavBar")
                case.results(let userData):
                    user.videosCount = userData.videos?.count
                    self.setApplicationRootVC(storyboardID: "MainTabBarController")
                }
            }
        } else {
            setApplicationRootVC(storyboardID: "WelcomeScreenNavBar")
        }
    }

}

extension LoadingViewController {
    func setApplicationRootVC(storyboardID: String) {
        let vc = self.storyboard?.instantiateViewController(identifier: storyboardID)
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
