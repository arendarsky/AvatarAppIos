//
//MARK:  SignUpViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SafariServices
import Amplitude

class SignUpViewController: XceFactorViewController {

    // MARK: - IBOutlet

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var mailingAgreementLabel: UILabel!
    
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!

    @IBOutlet private weak var registerButton: MainButton!
    @IBOutlet private weak var mailingAgreementButton: UIButton!
    @IBOutlet private weak var rulesButton: UIButton!
    
    
    // MARK: - Private Properties
    
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(),
                                                           type: .circleStrokeSpin,
                                                           color: .white,
                                                           padding: 8.0)
    private var isMailingConfirmed = true

    // MARK: - Public Properties
    
    var isConfirmSuccess = false
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isConfirmSuccess {
            registerButton.isEnabled = false
            loadingIndicator.enableCentered(in: view)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isConfirmSuccess {
            Globals.user.videosCount = 0
            self.setApplicationRootVC(storyboardID: "FirstUploadVC")
        }
    }

    // MARK: - Overrides
    
    /// Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Upload SuggestionVC" {
            //let vc = segue.destination as! FirstUploadVC
            //vc.isModalInPresentation = true
        } else if segue.identifier == "ConfirmVC from regist" {
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

    // MARK: - Network

    /// Authorization Request
    func authRequest(email: String, password: String) {
        loadingIndicator.enableCentered(in: view)
        registerButton.isEnabled = false
        
        Authentication.authorize(email: email, password: password) { serverResult in
            self.registerButton.isEnabled = true
            self.loadingIndicator.stopAnimating()
            
            switch serverResult {
            case .error(let error):
                switch error {
                case .unconfirmed:
                    Authentication.sendEmail(email: email) { result in
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
}

// MARK: - Actions

private extension SignUpViewController {
    
    /// Register Button Pressed
    @objc func registerButtonPressed(_ sender: UIButton) {
        guard let name = nameField.text, name != "",
              let email = emailField.text, email != "",
              let password = passwordField.text, password != "" else {
            showIncorrectUserInputAlert(title: "Заполнены не все необходимые поля",
                                        message: "Пожалуйста, введите данные еще раз")
            return
        }
        
        guard email.isValidEmail else {
            showIncorrectUserInputAlert(title: "Некорректный адрес",
                                        message: "Пожалуйста, введите почту еще раз")
            return
        }
        // Register Button Pressed Log
        Amplitude.instance()?.logEvent("registration_button_tapped")
        
        registerButton.isEnabled = false
        loadingIndicator.enableCentered(in: view)
        
        // Registration Session Results
        Authentication.registerNewUser(name: name,
                                       email: email,
                                       password: password,
                                       isMailingConfirmed: isMailingConfirmed) { serverResult in
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
                    self.showIncorrectUserInputAlert(title: "Такой аккаунт уже существует",
                                                     message: "Выполните вход в аккаунт или введите другие данные")
                    return
                }
            }
        }
    }
    
    /// Terms of Use Link
    @objc func termsOfUsePressed(_ sender: Any) {
        openSafariVC(self, with: .termsOfUse)
    }
    
    /// Mailing Agreement Pressed
    @objc func mailingAgreementPressed(_ sender: UIButton) {
        isMailingConfirmed.toggle()
        sender.tintColor = isMailingConfirmed ? .systemPurple : .placeholderText
        sender.setImage(UIImage(systemName: isMailingConfirmed ? "checkmark.circle.fill" : "circle"), for: .normal)
    }
}

// MARK: - Safari VC Delegate

extension SignUpViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    
    /// Hide the keyboard by pressing the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    /// Delete All Spaces
    func textFieldDidEndEditing(_ textField: UITextField) {
        if emailField.text?.contains(" ") ?? false {
            emailField.text?.removeAll { $0 == " " }
        }
    }
}

// MARK: - Private Methods

private extension SignUpViewController {
    
    func configureViews() {
        let cornerRadius: CGFloat = 8.0
        let padding: CGFloat = 10.0
        
        roundTwoViewsAsOne(left: nameLabel, right: nameField, cornerRadius: cornerRadius)
        roundTwoViewsAsOne(left: emailLabel, right: emailField, cornerRadius: cornerRadius)
        roundTwoViewsAsOne(left: passwordLabel, right: passwordField, cornerRadius: cornerRadius)
        
        nameField.addPadding(.both(padding))
        emailField.addPadding(.both(padding))
        passwordField.addPadding(.both(padding))
        
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        nameLabel.addTapGestureRecognizer { self.nameField.becomeFirstResponder() }
        emailLabel.addTapGestureRecognizer { self.emailField.becomeFirstResponder() }
        passwordLabel.addTapGestureRecognizer { self.passwordField.becomeFirstResponder() }
        
        mailingAgreementLabel.addTapGestureRecognizer {
            self.mailingAgreementPressed(self.mailingAgreementButton)
        }

        registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        rulesButton.addTarget(self, action: #selector(termsOfUsePressed), for: .touchUpInside)
        mailingAgreementButton.addTarget(self, action: #selector(mailingAgreementPressed), for: .touchUpInside)
    }

}
