//
//  FirstUploadVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class FirstUploadVC: UIViewController {

    @IBOutlet weak var uploadVideoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func uploadVideoButtonPressed(_ sender: Any) {
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        presentNewRootViewController(storyboardIdentifier: "MainTabBarController", animated: true)
        
    }
    
}
