//
//MARK:  LoadingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //System.clearance()
        //MARK:- All sound is muted at start
        Globals.isMuted = true
        checkToken()
    }
    
    func checkToken() {
        let userDetails = Defaults.getData()
        print(userDetails)
        if userDetails.token != "" {
            Globals.user.email = userDetails.email
            Globals.user.token = userDetails.token
            //MARK:- Fetch Profile Data
            Profile.getData(id: nil) { (serverResult) in
                print(serverResult)
                switch serverResult {
                case.error(let error):
                    print("Error: \(error)")
                    self.setApplicationRootVC(storyboardID: "WelcomeScreenNavBar", animation: .transitionCrossDissolve)
                case.results(let userData):
                    self.updateUserData(with: userData)
                    self.setApplicationRootVC(storyboardID: "MainTabBarController")
                }
            }
        } else {
            setApplicationRootVC(storyboardID: "WelcomeScreenNavBar", animation: .transitionCrossDissolve)
        }
    }

}
