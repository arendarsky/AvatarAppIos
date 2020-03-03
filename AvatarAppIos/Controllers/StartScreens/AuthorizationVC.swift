//
//  AuthorizationVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class AuthorizationVC: UIViewController {

    @IBOutlet weak var emailDescription: UILabel!
    @IBOutlet weak var passwordDescription: UILabel!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var authorizeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFieldsAndButtons()
    }

    
    @IBAction func authorizeButtonPressed(_ sender: Any) {
        showFeatureNotAvailableNowAlert()
    }
    
    
    
}

private extension AuthorizationVC {
    
    //MARK:- UI Configurations
    private func configureFieldsAndButtons() {
        emailField.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        passwordField.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        
        emailDescription.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        passwordDescription.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        
        emailDescription.layer.cornerRadius = 8
        passwordDescription.layer.cornerRadius = 8
        emailField.layer.cornerRadius = 8
        passwordField.layer.cornerRadius = 8
        emailField.addPadding(.both(10.0))
        passwordField.addPadding(.both(10.0))
        
        authorizeButton.configureHighlightedColors()
    }
}
