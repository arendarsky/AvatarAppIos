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
        addVideoButton.alignImageAndTitleVertically()
    }
    
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }

    @IBAction func addVideoButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        performSegue(withIdentifier: "Show First Video Pick VC", sender: sender)
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        presentNewRootViewController(storyboardIdentifier: "MainTabBarController", animated: true)
        
    }
    
}
