//
//MARK:  EmailConfirmationViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 17.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import InputMask
import NVActivityIndicatorView

class EmailConfirmationVC: XceFactorViewController {
    
    //@IBOutlet weak var enteredCodeField: UITextField!
    //var codeToCheck = ""
    //var didCompleteEnteringCode = false
    
    // MARK: - IBOutlets

    @IBOutlet private weak var listener: MaskedTextFieldDelegate!
    @IBOutlet private weak var doneButton: MainButton!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var resentEmailButton: UIButton!
    @IBOutlet private weak var incorrectEmailButton: UIButton!
    
    // MARK: - Public Properties
    
    weak var parentVC: UIViewController?
    var password = ""

    // MARK: - Private Properties

    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(),
                                                           type: .circleStrokeSpin,
                                                           color: .white,
                                                           padding: 8.0)
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        configureViews()
        //Authentication.sendEmail(email: Globals.user.email) { (result) in print(result) }
        //self.enteredCodeField.delegate = listener
    }

    // MARK: - Overrides
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Actions
    
    @objc private  func wrongEmailButtonPressed(_ sender: UIButton) {
        showReEnteringEmailAlert { _ in
            self.dismiss(animated: true)
        }
    }
    
    @objc private  func resendButtonPressed(_ sender: UIButton) {
        showReSendingEmailAlert { _ in
            Authentication.sendEmail(email: Globals.user.email) { result in
                print("sent with result: \(result)")
            }
        }
    }

    @objc private func doneButtonPressed(_ sender: UIButton) {
        loadingIndicator.enableCentered(in: view)

        // MARK: - Network Layer

        Authentication.authorize(email: Globals.user.email, password: password) { (serverResult) in
            self.loadingIndicator.stopAnimating()
            switch serverResult {
            case.error(let error):
                switch error {
                case .unconfirmed:
                    self.showIncorrectUserInputAlert(title: "Почта пока еще не подтверждена",
                                                     message: "Перейдите по ссылке в письме или запросите письмо еще раз")
                case.wrongInput:
                    self.dismiss(animated: true) {
                        self.showIncorrectUserInputAlert(title: "Неверный пароль",
                                                         message: "Почта успешно подтверждена, однако пароль неверный. Пожалуйста, введите пароль ещё раз.")
                    }
                default:
                    self.showErrorConnectingToServerAlert()
                }
                print("Error: \(error)")
            case.results(let isSuccess):
                if isSuccess {
                    if let vc = self.parentVC as? LoginViewController {
                        vc.isConfirmSuccess = true
                        self.dismiss(animated: true)
                    }
                    else if let vc = self.parentVC as? SignUpViewController {
                        vc.isConfirmSuccess = true
                        self.dismiss(animated: true)
                    }
                    else { print("Error initializing parent VC") }
                }
            }
        }
    }
    
}

// MARK: - MaskedTextFieldDelegateListener

extension EmailConfirmationVC: MaskedTextFieldDelegateListener {

    /// Hide the keyboard by pressing the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    /*
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        
        //print(value)
        codeToCheck = value
        didCompleteEnteringCode = complete
        if !(didCompleteEnteringCode || textField.text == "") {
            //enteredCodeField.text = codeToCheck + " _".times(6 - codeToCheck.count)
            //enteredCodeField.setCursorPosition(to: value.count)
        }
    }*/
}

// MARK: - Private Methods

private extension EmailConfirmationVC {
    
    func configureViews() {
        emailLabel.text = Globals.user.email
        //doneButton.addGradient()
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        resentEmailButton.addTarget(self, action: #selector(resendButtonPressed), for: .touchUpInside)
        incorrectEmailButton.addTarget(self, action: #selector(wrongEmailButtonPressed), for: .touchUpInside)
    }
}
