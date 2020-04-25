//
//  SignUpViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SafariServices

class SignUpViewController: XceFactorViewController {

    //MARK:- Properties
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: XceFactorWideButton!
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(), type: .circleStrokeSpin, color: .white, padding: 8.0)
    var isConfirmSuccess = false
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        configureFieldsAndButtons()
    }
    
    //MARK:- • Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isConfirmSuccess {
            registerButton.isEnabled = false
            loadingIndicator.enableCentered(in: view)
        }
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isConfirmSuccess {
            Globals.user.videosCount = 0
            self.setApplicationRootVC(storyboardID: "FirstUploadVC")
        }
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Upload SuggestionVC" {
            //let vc = segue.destination as! FirstUploadVC
            //vc.isModalInPresentation = true
        }
        else if segue.identifier == "ConfirmVC from regist" {
            let vc = segue.destination as! EmailConfirmationVC
            guard let password = passwordField.text else {
                self.showIncorrectUserInputAlert(title: "Введите пароль", message: "")
                return
            }
            vc.modalPresentationStyle = .fullScreen
            vc.password = password
            vc.parentVC = self
        }
    }
    
    //MARK:- UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    //MARK:- UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
    
    //MARK:- Register Button Pressed
    @IBAction private func registerButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        guard
            let name = nameField.text, name != "",
            let email = emailField.text, email != "",
            let password = passwordField.text, password != ""
        else {
            showIncorrectUserInputAlert(title: "Заполнены не все необходимые поля", message: "Пожалуйста, введите данные еще раз")
            return
        }
        
        guard email.isValidEmail else {
            showIncorrectUserInputAlert(title: "Некорректный адрес", message: "Пожалуйста, введите почту еще раз")
            return
        }
        
        registerButton.isEnabled = false
        loadingIndicator.enableCentered(in: view)
        
        //MARK:- Registration Session Results
        Authentication.registerNewUser(name: name, email: email, password: password) { (serverResult) in
            self.loadingIndicator.stopAnimating()
            self.registerButton.isEnabled = true
            
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert()
            case .results(let regResult):
                if regResult {
                    Globals.user.email = email
                    self.authRequest(email: email, password: password)
                    
                } else {
                    self.showIncorrectUserInputAlert(title: "Такой аккаунт уже существует", message: "Выполните вход в аккаунт или введите другие данные")
                    return
                }
            }
        }
        
    }
    
    //MARK:- Authorization Request
    func authRequest(email: String, password: String) {
        self.loadingIndicator.enableCentered(in: view)
        self.registerButton.isEnabled = false
        
        Authentication.authorize(email: email, password: password) { (serverResult) in
            self.registerButton.isEnabled = true
            self.loadingIndicator.stopAnimating()
            
            switch serverResult {
            case .error(let error):
                switch error {
                case .unconfirmed:
                    Authentication.sendEmail(email: email) { (result) in
                        print("Sending email result: \(result)")
                    }
                    self.performSegue(withIdentifier: "ConfirmVC from regist", sender: nil)
                default:
                    self.showErrorConnectingToServerAlert()
                }
                print("Error: \(error)")
            case .results(let isSuccess):
                if isSuccess {
                    Globals.user.videosCount = 0
                    self.setApplicationRootVC(storyboardID: "FirstUploadVC")
                }
            }
        }
    }
    
    //MARK:- Terms of Use Link
    @IBAction func termsOfUsePressed(_ sender: Any) {
        openSafariVC(self, with: .termsOfUse)
    }
    
}

//MARK:- Safari VC Delegate
extension SignUpViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


//MARK:- Hide the keyboard by pressing the return key
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    //MARK:- Delete All Spaces
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (emailField.text?.contains(" "))! {
            emailField.text?.removeAll(where: { (char) -> Bool in
                char == " "
            })
        }
    }
}

private extension SignUpViewController {
    
    //MARK:- Configure Views
    private func configureFieldsAndButtons() {
        let cornerRadius: CGFloat = 8.0
        let padding: CGFloat = 10.0
        
        roundTwoViewsAsOne(left: nameLabel, right: nameField, cornerRadius: cornerRadius)
        roundTwoViewsAsOne(left: emailLabel, right: emailField, cornerRadius: cornerRadius)
        roundTwoViewsAsOne(left: passwordLabel, right: passwordField, cornerRadius: cornerRadius)
        
        nameField.addPadding(.both(padding))
        emailField.addPadding(.both(padding))
        passwordField.addPadding(.both(padding))
        
        //registerButton.addGradient()
        
        //MARK:- Tap Gesture Recognizers
        nameLabel.addTapGestureRecognizer {
            self.nameField.becomeFirstResponder()
        }
        emailLabel.addTapGestureRecognizer {
            self.emailField.becomeFirstResponder()
        }
        passwordLabel.addTapGestureRecognizer {
            self.passwordField.becomeFirstResponder()
        }
    }

}
