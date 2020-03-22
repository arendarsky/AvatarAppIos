//
//  SettingsViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 21.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    //MARK:- Properties
    @IBOutlet weak var passwordHeader: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailHeader: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavBar()
        configureViews()
        addTapRecognizers()
    }
    
    private func tapAction() {
        performSegue(withIdentifier: "Change Settings", sender: nil)
    }
    
}

extension SettingsViewController {
    private func configureViews() {
        let cornerRadius: CGFloat = 8.0
        roundTwoViewsAsOne(left: passwordHeader, right: passwordLabel, cornerRadius: cornerRadius)
        roundTwoViewsAsOne(left: emailHeader, right: emailLabel, cornerRadius: cornerRadius)

        emailLabel.alpha = 0.5
        emailHeader.alpha = 0.5
    }
    
    private func addTapRecognizers() {
        passwordLabel.addTapGestureRecognizer(action: tapAction)
        passwordHeader.addTapGestureRecognizer(action: tapAction)
        emailHeader.addTapGestureRecognizer {
            print("email tapped")
        }
        emailLabel.addTapGestureRecognizer {
            print("email tapped")
        }
    }
}
