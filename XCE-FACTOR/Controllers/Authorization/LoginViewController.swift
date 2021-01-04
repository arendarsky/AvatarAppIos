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

final class LoginViewController: XceFactorViewController {

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

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private let authenticationManager = AuthenticationManager(networkClient: NetworkClient())
    private let profileManager = ProfileServicesManager(networkClient: NetworkClient())

    private var alertFactory: AlertFactoryProtocol?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Инициализирвоать в билдере, при переписи на MVP поправить:
        alertFactory = AlertFactory(viewController: self)

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
                self.alertFactory?.showAlert(type: .enterPassword)
                return
            }
            vc.password = password
            vc.parentVC = self
        }
    }
}

// MARK: - Actions

private extension LoginViewController {

    @objc func forgotPasswordButtonPressed(_ sender: Any) {
        alertFactory?.showResetPasswordAlert(email: emailField.text, allowsEditing: true) { enteredEmail in
            guard enteredEmail.isValidEmail else {
                self.alertFactory?.showAlert(type: .incorrectEmailAdress)
                return
            }
            
            self.loadingIndicator.enableCentered(in: self.view)
            self.resetPassword(email: enteredEmail)
        }
    }
    
    @objc func authorizeButtonPressed(_ sender: Any) {
        guard let email = emailField.text, email != "",
              let password = passwordField.text, password != "" else {
                self.alertFactory?.showAlert(type: .notAllFieldsFilled)
            return
        }
        
        //MARK:- ❗️Don't forget to remove exception for 'test'
        //|| email == "test"
        guard email.isValidEmail /*|| email == "test"*/ else {
            self.alertFactory?.showAlert(type: .incorrectAdress)
            return
        }

        let credentials = Credentials(email: email,
                                      password: password)
        
        Globals.user.email = email
        authorizeButton.isEnabled = false
        loadingIndicator.enableCentered(in: view)
    
        startAuthorization(with: credentials)
    }

    @objc func termsOfUsePressed(_ sender: Any) {
        openSafariVC(self, with: .termsOfUse)
    }
    
}

// MARK: - Service Layer

private extension LoginViewController {
    func startAuthorization(with credentials: Credentials) {
        authenticationManager.startAuthentication(with: credentials.email, credentials.password) { [weak self] result in
            guard let self = self else { return }

            self.authorizeButton.isEnabled = true
            self.loadingIndicator.stopAnimating()

            switch result {
            case .failure(let error):
                switch error {
                case .wrondCredentials:
                    self.alertFactory?.showAlert(type: .incorrectEmailOrPassword)
                case .unconfirmed:
                    self.authenticationManager.sendEmail(email: credentials.email)
                    self.performSegue(withIdentifier: "ConfirmVC from auth", sender: self)
                default:
                    self.showErrorConnectingToServerAlert()
                }
            case .success:
                self.loadingIndicator.enableCentered(in: self.view)
                self.authorizeButton.isEnabled = false

                self.setNotificationToken()
                self.getDataFromProfile()
            }
        }
    }

    func setNotificationToken() {
        // Messaging.messaging().fcmToken - получение токена из Firebase или из UserDefaults, если nil
        // TODO: Получить динамического токена по доку из Firebase:
        // https://firebase.google.com/docs/cloud-messaging/ios/client
        TokenAuthentication.setNotificationsToken(token: Messaging.messaging().fcmToken ?? Defaults.getFcmToken())
    }

    func resetPassword(email: String) {
        self.authenticationManager.resetPassword(email: email) { [weak self] result in
            guard let self = self else { return }

            self.loadingIndicator.stopAnimating()
            switch result {
            case .failure:
                self.alertFactory?.showAlert(type: .letterNotSend)
            case .success(let isSuccess):
                self.alertFactory?.showAlert(type: isSuccess ? .letterSend : .letterNotSend)
            }
        }
    }

    func getDataFromProfile() {
        profileManager.getUserData(for: nil) { result in
            self.authorizeButton.isEnabled = true
            self.loadingIndicator.stopAnimating()
            
            switch result {
            case .failure(let error):
                print("Error: \(error)")
                // TODO: Hanle Error
            case .success(let userData):
                self.updateUserData(with: userData)
                self.handlePossibleSoundError()
                self.setApplicationRootVC(storyboardID: "MainTabBarController")
            }
        }
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
        view.endEditing(true)
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
