//
//  WelcomeScreenVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class WelcomeScreenVC: UIViewController {

    @IBOutlet weak var authorizeButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        configureButtons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Go Casting unauthorized":
            navigationController?.navigationBar.isHidden  = true
            break
        case "Show AuthorizationVC":
            
            break
        case "Show RegistrationVC":
            
            break
        default:
            break
        }
    }
    
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
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
        //performSegue(withIdentifier: "Go Casting unauthorized", sender: sender)
        presentNewRootViewController(storyboardIdentifier: "MainTabBarController", animated: true)
    }
    
    private func configureButtons() {
        //❗️highlighted colors do not work because of gradient layer
        
        registerButton.addGradient()
        authorizeButton.addGradient()
    }
    
}
