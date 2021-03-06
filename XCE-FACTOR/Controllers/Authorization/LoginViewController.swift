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

    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var authorizeButton: XceFactorWideButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    
    var isConfirmSuccess = false
    private var loadingIndicator = NVActivityIndicatorView(
        frame: CGRect(),
        type: .circleStrokeSpin,
        color: .white,
        padding: 8.0)

    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFieldsAndButtons()
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    //MARK:- • Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isConfirmSuccess {
            authorizeButton.isEnabled = false
            loadingIndicator.enableCentered(in: view)
        }
    }
    
    //MARK:- • Did Appear
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

    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK:- Prepare for Segue
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
    
    //MARK:- UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    //MARK:- UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
    
    //MARK:- Forgot Password Button
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        showResetPasswordAlert(email: emailField.text) { (enteredEmail) in
            guard enteredEmail.isValidEmail else {
                self.showIncorrectUserInputAlert(title: "Некорректный адрес почты", message: "")
                return
            }
            self.loadingIndicator.enableCentered(in: self.view)
            Authentication.resetPassword(email: enteredEmail) { (isSuccess) in
                self.loadingIndicator.stopAnimating()
                if isSuccess {
                    self.showSimpleAlert(title: "Письмо отправлено", message: "Вам на почту было отправлено письмо с дальнейшими инструкциями по сбросу пароля")
                } else {
                    self.showErrorConnectingToServerAlert(title: "Не удалось отправить письмо", message: "Проверьте правильность ввода адреса почты и подключение к интернету")
                }
            }
        }
    }
    
    //MARK:- Authorize Button Pressed
    @IBAction func authorizeButtonPressed(_ sender: Any) {
        authorizeButton.scaleOut()
        guard
            let email = emailField.text, email != "",
            let password = passwordField.text, password != ""
        else {
            showIncorrectUserInputAlert(title: "Заполнены не все необходимые поля", message: "Пожалуйста, введите данные еще раз")
            return
        }
        
        //MARK:- ❗️Don't forget to remove exception for 'test'
        //|| email == "test"
        guard email.isValidEmail /*|| email == "test"*/ else {
            showIncorrectUserInputAlert(title: "Некорректный адрес", message: "Пожалуйста, введите почту еще раз")
            return
        }
        
        Globals.user.email = email
        authorizeButton.isEnabled = false
        loadingIndicator.enableCentered(in: view)
        
        //MARK:- Authorization Session Results
        Authentication.authorize(email: email, password: password) { (serverResult) in
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
                    Authentication.sendEmail(email: email) { (result) in
                        print("Sending email result: \(result)")
                    }
                    self.performSegue(withIdentifier: "ConfirmVC from auth", sender: sender)
                default:
                    self.showErrorConnectingToServerAlert()
                }
                //Globals.user.email = ""
            case .results(let isSuccess):
                if isSuccess {
                    //self.performSegue(withIdentifier: "Go Casting authorized", sender: sender)
                    self.loadingIndicator.enableCentered(in: self.view)
                    self.authorizeButton.isEnabled = false
                    
                    //MARK:- Send Token for Notifications
                    Authentication.setNotificationsToken(token: Messaging.messaging().fcmToken ?? Defaults.getFcmToken())
                    
                    //MARK:- Fetch Profile Data
                    Profile.getData(id: nil) { (serverResult) in
                        self.authorizeButton.isEnabled = true
                        self.loadingIndicator.stopAnimating()
                        
                        switch serverResult {
                        case.error(let error):
                            print("Error: \(error)")
                        case.results(let userData):
                            self.updateUserData(with: userData)
                            self.handlePossibleSoundError()
                            self.setApplicationRootVC(storyboardID: "MainTabBarController")
                        }
                    }
                }
            }
        }
        //showFeatureNotAvailableNowAlert()
    }
    
    //MARK:- Terms of Use Link
    @IBAction func termsOfUsePressed(_ sender: Any) {
        openSafariVC(self, with: .termsOfUse)
    }
    
}

//MARK:- Safari VC Delegate
extension LoginViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Hide the keyboard by pressing the return key
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    //MARK:- Delete All Spaces
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.contains(" "))! {
            textField.text?.removeAll(where: { (char) -> Bool in
                char == " "
            })
        }
    }
}

private extension LoginViewController {
    
    //MARK:- Configure Views
    private func configureFieldsAndButtons() {
        let padding: CGFloat = 10.0
        let cornerRadius: CGFloat = 8.0
        
        roundTwoViewsAsOne(left: emailLabel, right: emailField, cornerRadius: cornerRadius)
        roundTwoViewsAsOne(left: passwordLabel, right: passwordField, cornerRadius: cornerRadius)
        
        emailField.addPadding(.both(padding))
        passwordField.addPadding(.both(padding))
        
        //authorizeButton.addGradient()
        
        //MARK:- Tap Gesture Recognizers
        emailLabel.addTapGestureRecognizer {
            self.emailField.becomeFirstResponder()
        }
        passwordLabel.addTapGestureRecognizer {
            self.passwordField.becomeFirstResponder()
        }
        
        if #available(iOS 13.0, *) {
        } else {
            forgotPasswordButton.setTitleColor(UIColor.lightGray.withAlphaComponent(0.5), for: .normal)
        }
    }
    
}
