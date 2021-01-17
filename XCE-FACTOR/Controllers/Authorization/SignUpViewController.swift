//
//  AvatarAppIos
//
//  Created by Владислав on 29.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SafariServices
import Amplitude

final class SignUpViewController: XceFactorViewController {

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

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить:
    private var authenticationManager = AuthenticationManager(networkClient: NetworkClient())

    private var alertFactory: AlertFactoryProtocol?

    // MARK: - Public Properties
    
    var isConfirmSuccess = false
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Инициализирвоать в билдере, при переписи на MVP поправить:
        alertFactory = AlertFactory(viewController: self)
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
                alertFactory?.showAlert(type: .enterPassword)
                return
            }
            vc.modalPresentationStyle = .fullScreen
            vc.password = password
            vc.parentVC = self
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
                alertFactory?.showAlert(type: .notAllFieldsFilled)
                return
        }
        
        guard email.isValidEmail else {
            alertFactory?.showAlert(type: .incorrectAdress)
            return
        }

        let userAuthModel = UserAuthModel(name: name,
                                          email: email,
                                          password: password,
                                          isConsentReceived: isMailingConfirmed)
        
        // Register Button Pressed Log
        Amplitude.instance()?.logEvent("registration_button_tapped")
        
        registerButton.isEnabled = false
        loadingIndicator.enableCentered(in: view)
        
        // Registration Session Results
        registerNewUser(with: userAuthModel)
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

// MARK: - Network Layer

private extension SignUpViewController {
    func registerNewUser(with userAuthModel: UserAuthModel) {
        authenticationManager.registerUser(with: userAuthModel) { [weak self] result in
            guard let self = self else { return }

            self.loadingIndicator.stopAnimating()
            self.registerButton.isEnabled = true

            switch result {
            case .failure(let error):
                switch error {
                case .userExists:
                    self.alertFactory?.showAlert(type: .accountAlreadyExists)
                case .unconfirmed:
                    self.authenticationManager.sendEmail(email: userAuthModel.email)
                    self.performSegue(withIdentifier: "ConfirmVC from regist", sender: nil)
                default:
                    self.alertFactory?.showAlert(type: .connectionToServerError)
                }
            case .success:
                Globals.user.videosCount = 0
                self.setApplicationRootVC(storyboardID: "FirstUploadVC")
            }
        }
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
