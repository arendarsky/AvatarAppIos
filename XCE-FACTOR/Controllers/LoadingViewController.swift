//
//MARK:  LoadingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class LoadingViewController: XceFactorViewController {

    // MARK: - Private Properties

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private let profileManager = ProfileServicesManager(networkClient: NetworkClient())

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        /// All sound is muted at start
        Globals.isMuted = true
        checkToken()
    }

    // MARK: - Private Methods
    
    private func checkToken() {
        let userDetails = Defaults.getUserData()
        print(userDetails)
        if userDetails.token != "" {
            Globals.user.email = userDetails.email
            Globals.user.token = userDetails.token

            profileManager.getUserData(for: nil) { result in
                switch result {
                case .failure(let error):
                    print("Error: \(error)")
                    self.setApplicationRootVC(storyboardID: "WelcomeScreenNavBar",
                                              transition: .transitionCrossDissolve)
                case .success(let userData):
                    self.updateUserData(with: userData)
                    self.setApplicationRootVC(storyboardID: "MainTabBarController")
                }
            }
        } else {
            setApplicationRootVC(storyboardID: "WelcomeScreenNavBar",
                                 transition: .transitionCrossDissolve)
        }
    }
}
