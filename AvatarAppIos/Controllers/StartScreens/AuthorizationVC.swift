//
//  AuthorizationVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class AuthorizationVC: UIViewController {

    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var authorizeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
    }

    
    @IBAction func authorizeButtonPressed(_ sender: Any) {
        showFeatureNotAvailableNowAlert()
    }
    
    
    private func configureTextFields() {
        emailField.addPadding(.both(10.0))
        passwordField.addPadding(.both(10.0))
    }
}
