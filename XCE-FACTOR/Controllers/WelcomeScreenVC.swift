//
//  WelcomeScreenVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class WelcomeScreenVC: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var authorizeButton: MainButton!
    @IBOutlet weak var registerButton: MainButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        clearNavigationBar(forBar: navigationController?.navigationBar,
                           clearBorder: true)
        configureButtons()
    }

    // MARK: - Navigation
    
    @objc func authorizeButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show AuthorizationVC", sender: sender)
    }
    
    @objc func registerButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show RegistrationVC", sender: sender)
    }

    // MARK: - IBActions

    // TODO: Разобраться, что делать с этой кнопкой
    // Нужна ли она вообще
    @IBAction func skipButtonPressed(_ sender: Any) {
        setApplicationRootVC(storyboardID: "MainTabBarController")
    }
    
}

// MARK: - Private Methods

private extension WelcomeScreenVC {

    func configureButtons() {
        authorizeButton.addTarget(self, action: #selector(authorizeButtonPressed), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
    }
}
