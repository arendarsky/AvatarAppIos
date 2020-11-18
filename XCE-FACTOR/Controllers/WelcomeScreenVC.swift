//
//  WelcomeScreenVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class WelcomeScreenVC: XceFactorViewController {

    @IBOutlet weak var authorizeButton: XceFactorWideButton!
    @IBOutlet weak var registerButton: XceFactorWideButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        clearNavigationBar(forBar: navigationController!.navigationBar, clearBorder: true)
        
    }
    
    //MARK:- UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    //MARK:- UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
    
    @IBAction func authorizeButtonPressed(_ sender: Any) {
        authorizeButton.scaleOut()
        performSegue(withIdentifier: "Show AuthorizationVC", sender: sender)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        registerButton.scaleOut()
        performSegue(withIdentifier: "Show RegistrationVC", sender: sender)
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        setApplicationRootVC(storyboardID: "MainTabBarController")
    }
    
}
