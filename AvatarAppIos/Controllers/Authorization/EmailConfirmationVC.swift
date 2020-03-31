//
//  EmailConfirmationViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 17.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import InputMask

class EmailConfirmationVC: UIViewController, MaskedTextFieldDelegateListener {
    //MARK:- Properties
    @IBOutlet weak var listener: MaskedTextFieldDelegate!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    //@IBOutlet weak var enteredCodeField: UITextField!
    var password = ""
    //var codeToCheck = ""
    //var didCompleteEnteringCode = false
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        configureViews()
        //Authentication.sendEmail(email: Globals.user.email) { (result) in print(result) }
        //self.enteredCodeField.delegate = listener
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK:- Wrong Email Button Pressed
    @IBAction func wrongEmailButtonPressed(_ sender: UIButton) {
        showReEnteringEmailAlert { (okAction) in
            self.dismiss(animated: true)
        }
    }
    
    //MARK:- Resend Confirm Button Pressed
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        showReSendingEmailAlert { (action) in
            Authentication.sendEmail(email: Globals.user.email) { (result) in
                print("sent with result: \(result)")
            }
        }
        //enteredCodeField.text = ""
    }
    
    //MARK:- Button Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
    
    //MARK:- Done Button Pressed
    @IBAction private func doneButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        Authentication.authorize(email: Globals.user.email, password: password) { (serverResult) in
            switch serverResult {
            case.error(let error):
                switch error {
                case .unconfirmed:
                    self.showIncorrectUserInputAlert(title: "Почта пока еще не подтверждена", message: "Перейдите по ссылке в письме или запросите письмо еще раз", tintColor: .label)
                case.wrongInput:
                    self.dismiss(animated: true) {
                        self.showIncorrectUserInputAlert(title: "Неверный пароль", message: "Почта успешно подтверждена, однако пароль неверный. Пожалуйста, введите пароль ещё раз.", tintColor: .label)
                    }
                default:
                    self.showErrorConnectingToServerAlert()
                }
                print("Error: \(error)")
            case.results(let result):
                if result == "success" {
                    self.dismiss(animated: true) {
                        if let vc = self.navigationController?.viewControllers.last as? RegistrationVC {
                            vc.authRequest(email: Globals.user.email, password: self.password)
                        }
                       //manage controllers
                        //self.presentNewRootViewController()
                    }
                }
            }
        }
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

//MARK:- Hide the keyboard by pressing the return key
extension EmailConfirmationVC {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

private extension EmailConfirmationVC {
    //MARK:- Configure Views
    func configureViews() {
        emailLabel.text = Globals.user.email
        doneButton.addGradient()
    }
}
