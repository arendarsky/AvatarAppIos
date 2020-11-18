//
//MARK:  LoginViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SafariServices
import Firebase

class LoginViewController: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!

    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!

    @IBOutlet private weak var xceFactorRulesButton: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var authorizeButton: MainButton!

    // MARK: - Public Properties
    
    var isConfirmSuccess = false

    // MARK: - Private Properties

    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(),
                                                           type: .circleStrokeSpin,
                                                           color: .white,
                                                           padding: 8.0)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureFields()
        configureButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isConfirmSuccess {
            authorizeButton.isEnabled = false
            loadingIndicator.enableCentered(in: view)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isConfirmSuccess {
            /**❗️assuming that NOW user has to confirm his email only when he registered
             (should change this after we'll have an ability to change email)
             */
            Globals.user.videosCount = 0
            self.setApplicationRootVC(storyboardID: "MainTabBarController")
        }
    }

    // MARK: - Overrides

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - Transitions

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmVC from auth" {
            let vc = segue.destination as! EmailConfirmationVC
            vc.modalPresentationStyle = .fullScreen
            guard let password = passwordField.text else {
                self.showIncorrectUserInputAlert(title: "Введите пароль", message: "")
                return
            }
            vc.password = password
            vc.parentVC = self
        }
    }
    
    // MARK: - Handlers
    
    @objc func forgotPasswordButtonPressed(_ sender: Any) {
        showResetPasswordAlert(email: emailField.text) { enteredEmail in
            guard enteredEmail.isValidEmail else {
                self.showIncorrectUserInputAlert(title: "Некорректный адрес почты", message: "")
                return
            }

            self.loadingIndicator.enableCentered(in: self.view)
            Authentication.resetPassword(email: enteredEmail) { isSuccess in
                self.loadingIndicator.stopAnimating()
                isSuccess
                    ? self.showSimpleAlert(title: "Письмо отправлено",
                                           message: "Вам на почту было отправлено письмо с дальнейшими инструкциями по сбросу пароля")
                    : self.showErrorConnectingToServerAlert(title: "Не удалось отправить письмо",
                                                            message: "Проверьте правильность ввода адреса почты и подключение к интернету")
            }
        }
    }
    
    @objc func authorizeButtonPressed(_ sender: Any) {
        guard let email = emailField.text, email != "",
              let password = passwordField.text, password != "" else {
            showIncorrectUserInputAlert(title: "Заполнены не все необходимые поля",
                                        message: "Пожалуйста, введите данные еще раз")
            return
        }
        
        //MARK:- ❗️Don't forget to remove exception for 'test'
        //|| email == "test"
        guard email.isValidEmail /*|| email == "test"*/ else {
            showIncorrectUserInputAlert(title: "Некорректный адрес",
                                        message: "Пожалуйста, введите почту еще раз")
            return
        }
        
        Globals.user.email = email
        authorizeButton.isEnabled = false
        loadingIndicator.enableCentered(in: view)
        
        // Authorization Session Results
        Authentication.authorize(email: email, password: password) { serverResult in
            self.authorizeButton.isEnabled = true
            self.loadingIndicator.stopAnimating()
            
            switch serverResult {
            case .error(let error):
                switch error {
                case.wrongInput:
                    self.showIncorrectUserInputAlert(
                        title: "Неверный e-mail или пароль",
                        message: "Пожалуйста, введите данные снова"
                    )
                case.unconfirmed:
                    Authentication.sendEmail(email: email) { result in
                        print("Sending email result: \(result)")
                    }
                    self.performSegue(withIdentifier: "ConfirmVC from auth", sender: sender)
                default:
                    self.showErrorConnectingToServerAlert()
                }
                //Globals.user.email = ""
            case .results(let isSuccess):
                guard isSuccess else { return }
                //self.performSegue(withIdentifier: "Go Casting authorized", sender: sender)
                self.loadingIndicator.enableCentered(in: self.view)
                self.authorizeButton.isEnabled = false
                
                Authentication.setNotificationsToken(token: Messaging.messaging().fcmToken ?? Defaults.getFcmToken())
                
                Profile.getData(id: nil) { serverResult in
                    self.authorizeButton.isEnabled = true
                    self.loadingIndicator.stopAnimating()
                    
                    switch serverResult {
                    case.error(let error):
                        print("Error: \(error)")
                        // TODO: Hanle Error
                    case.results(let userData):
                        self.updateUserData(with: userData)
                        self.handlePossibleSoundError()
                        self.setApplicationRootVC(storyboardID: "MainTabBarController")
                    }
                }
            }
        }
    }

    @objc func termsOfUsePressed(_ sender: Any) {
        openSafariVC(self, with: .termsOfUse)
    }
    
}

// MARK: - Safari VC Delegate

extension LoginViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.contains(" "))! {
            textField.text?.removeAll { $0 == " " }
        }
    }
}

// MARK: - Private Methods

private extension LoginViewController {
    
    func configureFields() {
        let padding: CGFloat = 10.0
        let cornerRadius: CGFloat = 8.0
        
        roundTwoViewsAsOne(left: emailLabel, right: emailField, cornerRadius: cornerRadius)
        roundTwoViewsAsOne(left: passwordLabel, right: passwordField, cornerRadius: cornerRadius)

        emailField.delegate = self
        passwordField.delegate = self
        
        emailField.addPadding(.both(padding))
        passwordField.addPadding(.both(padding))
        
        emailLabel.addTapGestureRecognizer { self.emailField.becomeFirstResponder() }
        passwordLabel.addTapGestureRecognizer { self.passwordField.becomeFirstResponder() }
    }

    func configureButtons() {
        if #available(iOS 13.0, *) {} else {
            forgotPasswordButton.setTitleColor(UIColor.lightGray.withAlphaComponent(0.5), for: .normal)
        }

        authorizeButton.addTarget(self, action: #selector(authorizeButtonPressed), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        xceFactorRulesButton.addTarget(self, action: #selector(termsOfUsePressed), for: .touchUpInside)
    }
}
