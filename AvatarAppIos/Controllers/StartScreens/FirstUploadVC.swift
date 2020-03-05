//
//  FirstUploadVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class FirstUploadVC: UIViewController {

    @IBOutlet weak var addVideoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVideoButton.configureHighlightedColors()
    }

    @IBAction func addVideoButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show First Video Pick VC", sender: sender)
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        presentNewRootViewController(storyboardIdentifier: "MainTabBarController", animated: true)
        
    }
    
}
