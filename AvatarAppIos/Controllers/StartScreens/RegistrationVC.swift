//
//  RegistrationVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class RegistrationVC: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextFields()
    }

    
    @IBAction private func registerButtonPressed(_ sender: Any) {
        
        showFeatureNotAvailableNowAlert(title: "Регстрация сейчас не доступна", message: "Но если так хочется, то сейчас произойдёт переход на следующий экран (спойлер - там делать тоже особо нечего)", shouldAddCancelButton: true) { (action) in
            self.performSegue(withIdentifier: "Show Upload SuggestionVC", sender: sender)
        }
    }
    
    
    private func configureTextFields() {
        nameField.addPadding(.both(10.0))
        emailField.addPadding(.both(10.0))
        passwordField.addPadding(.both(10.0))
    }
}
