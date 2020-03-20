//
//  RegistrationVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RegistrationVC: UIViewController {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    private var loadingIndicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        configureFieldsAndButtons()
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Upload SuggestionVC" {
            //let vc = segue.destination as! FirstUploadVC
            //vc.isModalInPresentation = true
        }
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
        
        registerButton.isEnabled = false
        enableLoadingIndicator()
        
        //MARK:- Registration Session Results
        Authentication.registerNewUser(name: name, email: email, password: password) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.disableLoadingIndicator()
                self.registerButton.isEnabled = true
                self.showErrorConnectingToServerAlert()
            case .results(let regResult):
                if regResult {
                    //MARK:- Authorization Session Results
                    Authentication.authorize(email: email, password: password) { (serverResult) in
                        self.registerButton.isEnabled = true
                        self.disableLoadingIndicator()
                        switch serverResult {
                        case .error(let error):
                            print("Error: \(error)")
                            self.showErrorConnectingToServerAlert()
                        case .results(let result):
                            if result == "success" {
                                //self.performSegue(withIdentifier: "Show Upload SuggestionVC", sender: sender)
                                self.presentNewRootViewController(storyboardIdentifier: "FirstUploadVC", animated: true, isNavBarHidden: false)
                            }
                        }
                    }
                } else if !regResult {
                    
                    self.showIncorrectUserInputAlert(title: "Такой аккаунт уже существует", message: "Выполните вход в аккаунт или введите другие данные")
                    return
                }
            }
        }
        
        
    }

}

//MARK:- Hide the keyboard by pressing the return key
extension RegistrationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}

private extension RegistrationVC {
    
    //MARK:- UI Configurations
    private func configureFieldsAndButtons() {
        let cornerRadius: CGFloat = 8.0
        let padding: CGFloat = 10.0
        
        let labelMask: CACornerMask = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        
        let fieldMask: CACornerMask = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        
        emailField.layer.maskedCorners = fieldMask
        passwordField.layer.maskedCorners = fieldMask
        nameField.layer.maskedCorners = fieldMask
        
        emailLabel.layer.maskedCorners = labelMask
        passwordLabel.layer.maskedCorners = labelMask
        nameLabel.layer.maskedCorners = labelMask
        
        emailLabel.layer.cornerRadius = cornerRadius
        passwordLabel.layer.cornerRadius = cornerRadius
        nameLabel.layer.cornerRadius = cornerRadius
        
        emailField.layer.cornerRadius = cornerRadius
        passwordField.layer.cornerRadius = cornerRadius
        
        nameField.addPadding(.both(padding))
        emailField.addPadding(.both(padding))
        passwordField.addPadding(.both(padding))
        
        registerButton.configureHighlightedColors()
        registerButton.addGradient()
    }
    
    //MARK:- Configure Loading Indicator
    private func enableLoadingIndicator() {
        if loadingIndicator == nil {
            
            let width: CGFloat = 40.0
            let frame = CGRect(x: (view.bounds.midX - width/2), y: (view.bounds.midY - width/2), width: width, height: width)
            
            loadingIndicator = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .white, padding: 8.0)
            loadingIndicator?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loadingIndicator?.layer.cornerRadius = 4

            view.addSubview(loadingIndicator!)
        }
        loadingIndicator!.startAnimating()
        loadingIndicator!.isHidden = false
    }
    
    private func disableLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.isHidden = true
    }
}
