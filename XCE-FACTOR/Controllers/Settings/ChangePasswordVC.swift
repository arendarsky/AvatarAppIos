//
//  AvatarAppIos
//
//  Created by Владислав on 21.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ChangePasswordVC: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var oldPasswordView: UIView!
    @IBOutlet weak var oldPasswordLabel: UILabel!
    @IBOutlet weak var oldPasswordField: UITextField!
    
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var newPasswordLabel: UILabel!
    @IBOutlet weak var newPasswordField: UITextField!
    
    @IBOutlet weak var changeSettingsNavBar: UINavigationBar!
    @IBOutlet weak var changeSettingsNavItem: UINavigationItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var resetPasswordButton: UIButton!

    // MARK: - Private Properties
    
    private let activityIndicator = UIActivityIndicatorView()
    private let loadingIndicator = NVActivityIndicatorView(frame: CGRect(),
                                                           type: .circleStrokeSpin,
                                                           color: .systemPurple,
                                                           padding: 8.0)
    
    ///The number of tries to change the password. If greater than 1, forces 'resetPasswordButton' to display
    private var numberOfTries = 0

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private let authenticationManager = AuthenticationManager(networkClient: NetworkClient())

    private var alertFactory: AlertFactoryProtocol?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Инициализирвоать в билдере, при переписи на MVP поправить:
        alertFactory = AlertFactory(viewController: self)

        configureViews()
        configureButtons()
    }

    // MARK: - Actions
    
    @objc func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonPressed(_ sender: Any) {
        guard let oldPassword = oldPasswordField.text, oldPassword.count > 0 else {
            alertFactory?.showAlert(type: .emptyPasswordFields)
            return
        }
        oldPasswordView.borderWidthV = 0.0
        guard let newPassword = newPasswordField.text, newPassword.count > 0 else {
            alertFactory?.showAlert(type: .emptyPasswordField)
            return
        }
        newPasswordView.borderWidthV = 0.0

        activityIndicator.enableInNavBar(of: changeSettingsNavItem)
        Profile.changePassword(oldPassword: oldPassword, newPassword: newPassword) { (serverResult) in
            self.activityIndicator.disableInNavBar(of: self.changeSettingsNavItem, replaceWithButton: self.saveButton)
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.newPasswordView.borderWidthV = 0.0
                self.oldPasswordView.borderWidthV = 0.0
                self.alertFactory?.showAlert(type: .failedChangePassword)
            case .results(let isCorrect):
                if isCorrect {
                    //self.activityIndicator.disableInNavBar(of: self.changeSettingsNavItem, replaceWithButton: self.saveButton)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.alertFactory?.showAlert(type: .enterIncorrectPassword)
                    self.numberOfTries += 1
                    self.resetPasswordButton.isHidden = self.numberOfTries < 2
                    self.newPasswordView.borderWidthV = 0.0
                    self.oldPasswordView.borderWidthV = 0.0
                    self.oldPasswordField.text = ""
                    self.newPasswordField.text = ""
                }
            }
        }
    }

    @objc func resetPasswordButtonPressed(_ sender: Any) {
        alertFactory?.showResetPasswordAlert(email: Globals.user.email, allowsEditing: false) { enteredEmail in
            guard enteredEmail.isValidEmail else {
                self.alertFactory?.showAlert(type: .incorrectEmailAdress)
                return
            }

            self.loadingIndicator.enableCentered(in: self.view)
            self.resetPassword(email: enteredEmail)
        }
    }
}

// MARK: - Network Layer

private extension ChangePasswordVC {
    func resetPassword(email: String) {
        authenticationManager.resetPassword(email: email) { [weak self] result in
            guard let self = self else { return}

            self.loadingIndicator.stopAnimating()
            switch result {
            case .failure:
                self.alertFactory?.showAlert(type: .failedSendLetter)
            case .success(let isSuccess):
                self.alertFactory?.showAlert(type: isSuccess ? .letterSend : .failedSendLetter)
            }
        }
    }
}

// MARK: - Text Field Delegate

extension ChangePasswordVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        /// Check old password field
        if oldPasswordField.text?.count == 0 {
            oldPasswordView.borderWidthV = 1.0
            oldPasswordView.borderColorV = .systemRed
        } else {
            oldPasswordView.borderWidthV = 0.0
        }
        
        if textField.text == oldPasswordField.text {
            return
        }
        ///Check new password field
        if newPasswordField.text?.count == 0 {
            newPasswordView.borderWidthV = 1.0
            newPasswordView.borderColorV = .systemRed
        } else {
            newPasswordView.borderWidthV = 0.0
        }
    }
}

// MARK: - Private Methods

private extension ChangePasswordVC {

    func configureViews() {
        //let cornerRadius: CGFloat = 8.0
        let padding: CGFloat = 10.0
        
        oldPasswordLabel.backgroundColor = oldPasswordField.backgroundColor
        newPasswordLabel.backgroundColor = oldPasswordField.backgroundColor
        if #available(iOS 13.0, *) {} else {
            changeSettingsNavBar.barTintColor = .darkGray
            changeSettingsNavBar.tintColor = .white
            resetPasswordButton.setTitleColor(UIColor.lightGray.withAlphaComponent(0.5), for: .normal)
        }
        
        oldPasswordField.addPadding(.both(padding))
        newPasswordField.addPadding(.both(padding))
        
        oldPasswordLabel.addTapGestureRecognizer {
            self.oldPasswordField.becomeFirstResponder()
        }
        newPasswordLabel.addTapGestureRecognizer {
            self.newPasswordField.becomeFirstResponder()
        }
        
        oldPasswordField.delegate = self
        newPasswordField.delegate = self
        oldPasswordField.becomeFirstResponder()
    }

    func configureButtons() {
        dismissButton.target = self
        dismissButton.action = #selector(cancelButtonPressed)

        saveButton.target = self
        saveButton.action = #selector(saveButtonPressed)

        resetPasswordButton.addTarget(self,
                                      action: #selector(resetPasswordButtonPressed),
                                      for: .touchUpInside)
    }
}
