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

    @IBAction func authorizeButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show AuthorizationVC", sender: sender)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show RegistrationVC", sender: sender)
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        //performSegue(withIdentifier: "Go Casting unauthorized", sender: sender)
        guard let tabBarController = storyboard?.instantiateViewController(identifier: "MainTabBarController") else { return }
        tabBarController.modalPresentationStyle = .overCurrentContext
        //MARK:- ⬇️ Below we can see 3 different options for presenting Casting Screen:
        ///1) Just present it modally in fullscreen
        ///   + good animation
        ///   - the welcoming screen after presentation still stays in memory and that's very bad
        
        //present(vc, animated: true, completion: nil)
        
        ///2) Change Root View Controller to the Casting Screen
        ///   + good for memory
        ///   - no animation
        /*
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
         */
        
        ///3) Set New Array of Controllers of NavController ❗️(Using Now)❗️
        ///   + good for memory
        ///   - animation is quite simple
        ///   - have to hide Navigation Bar manually in order to keep correct layout.
        ///         This might result in some problems in the future if we would need to open smth from Casting Screen
        
        let newViewControllers: [UIViewController] = [tabBarController]
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setViewControllers(newViewControllers, animated: true)
    }
    
    func configureButtons() {
        registerButton.configureHighlightedColors()
        authorizeButton.configureHighlightedColors()
    }
    
}
