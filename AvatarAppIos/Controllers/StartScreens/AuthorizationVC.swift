//
//  AuthorizationVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class AuthorizationVC: UIViewController {

    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var authorizeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFieldsAndButtons()
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    @IBAction func authorizeButtonPressed(_ sender: Any) {
        guard
            let email = emailField.text, email != "",
            let password = passwordField.text, password != ""
        else {
            showIncorrectUserInputAlert(title: "Заполнены не все необходимые поля", message: "Пожалуйста, введите данные еще раз")
            return
        }
        
        //MARK:- Authorization Session Results
        Authentication.authorize(email: email, password: password) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert()
            case .results(let result):
                if result == "success" {
                    //self.performSegue(withIdentifier: "Go Casting authorized", sender: sender)
                    //MARK:- 3 different options for presenting Casting Screen are described in WelcomeScreenVC.swift file
                    
                    guard let tabBarController = self.storyboard?.instantiateViewController(identifier: "MainTabBarController") else { return }
                    tabBarController.modalPresentationStyle = .overCurrentContext
                    
                    let newViewControllers: [UIViewController] = [tabBarController]
                    self.navigationController?.navigationBar.isHidden = true
                    self.navigationController?.setViewControllers(newViewControllers, animated: true)
                    
                }
            }
        }
        //showFeatureNotAvailableNowAlert()
    }
    
}

//MARK:- Hide the keyboard by pressing the return key
extension AuthorizationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}

private extension AuthorizationVC {
    
    //MARK:- UI Configurations
    private func configureFieldsAndButtons() {
        let padding: CGFloat = 10.0
        let cornerRadius: CGFloat = 8.0
        
        emailField.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        passwordField.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        
        emailLabel.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        passwordLabel.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        
        emailLabel.layer.cornerRadius = cornerRadius
        passwordLabel.layer.cornerRadius = cornerRadius
        
        emailField.layer.cornerRadius = cornerRadius
        passwordField.layer.cornerRadius = cornerRadius
        
        emailField.addPadding(.both(padding))
        passwordField.addPadding(.both(padding))
        
        authorizeButton.configureHighlightedColors()
    }
}
