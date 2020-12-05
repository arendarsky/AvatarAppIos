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
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureButtons()
    }

    // MARK: - Actions
    
    @objc func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonPressed(_ sender: Any) {
        guard let oldPassword = oldPasswordField.text, oldPassword.count > 0 else {
            showIncorrectUserInputAlert(title: "Пустое поле пароля",
                                        message: "Пожалуйста, введите старый и новый пароли")
            return
        }
        oldPasswordView.borderWidthV = 0.0
        guard let newPassword = newPasswordField.text, newPassword.count > 0 else {
            showIncorrectUserInputAlert(title: "Пустое поле пароля",
                                        message: "Пожалуйста, введите новый пароль")
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
                self.showIncorrectUserInputAlert(title: "Не удалось изменить пароль",
                                                 message: "Проверьте подключение к интернету и попробуйте снова")
            case .results(let isCorrect):
                if isCorrect {
                    //self.activityIndicator.disableInNavBar(of: self.changeSettingsNavItem, replaceWithButton: self.saveButton)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showIncorrectUserInputAlert(title: "Введён неверный пароль",
                                                     message: "Введите корректный пароль и попробуйте снова")
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
        showResetPasswordAlert(email: Globals.user.email, allowsEditing: false) { enteredEmail in
            guard enteredEmail.isValidEmail else {
                self.showIncorrectUserInputAlert(title: "Некорректный адрес почты", message: "")
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
                self.showErrorConnectingToServerAlert(title: "Не удалось отправить письмо",
                                                      message: "Проверьте правильность ввода адреса почты и подключение к интернету")
            case .success(let isSuccess):
                isSuccess
                    ? self.showSimpleAlert(title: "Письмо отправлено",
                                           message: "Вам на почту было отправлено письмо с дальнейшими инструкциями по сбросу пароля")
                    : self.showErrorConnectingToServerAlert(title: "Не удалось отправить письмо",
                                                            message: "Проверьте правильность ввода адреса почты и подключение к интернету")
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
