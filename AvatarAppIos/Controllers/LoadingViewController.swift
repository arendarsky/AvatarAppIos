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
            presentNewRootViewController(animated: false)
            user.email = userDetails.email
            user.token = userDetails.token
        } else {
            performSegue(withIdentifier: "Show WelcomeVC on Load", sender: nil)
        }
    }

}
