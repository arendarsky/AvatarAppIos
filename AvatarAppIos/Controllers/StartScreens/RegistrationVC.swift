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
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        configureTextFields()
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    //MARK:- Register Button Pressed
    @IBAction private func registerButtonPressed(_ sender: Any) {
        
        guard
            let name = nameField.text, name != "",
            let email = emailField.text, email != "",
            let password = passwordField.text, password != ""
        else {
            showIncorrectUserInputAlert(title: "Заполнены не все необходимые поля", message: "Пожалуйста, введите данные еще раз")
            return
        }
        
        //MARK:- Registration Session Results
        Authentication.registerNewUser(name: name, email: email, password: password) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert()
            case .results(let regResult):
                if regResult == "success" {
                    //MARK:- Authorization Session Results
                    Authentication.authorize(email: email, password: password) { (serverResult) in
                        switch serverResult {
                        case .error(let error):
                            print("Error: \(error)")
                            self.showErrorConnectingToServerAlert()
                        case .results(let result):
                            if result == "success" {
                                self.performSegue(withIdentifier: "Show Upload SuggestionVC", sender: sender)
                            }
                        }
                    }
                } else {
                    //self.showIncorrectUserInputAlert(title: "Такой аккаунт уже существует", message: "Выполните вход в аккаунт или введите другие данные")
                    return
                }
            }
        }
        
        
    }
    
    
    //MARK:- Configure Text Fields
    private func configureTextFields() {
        nameField.addPadding(.both(10.0))
        emailField.addPadding(.both(10.0))
        passwordField.addPadding(.both(10.0))
    }
}

//MARK:- Hide the keyboard by pressing the return key
extension RegistrationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}
