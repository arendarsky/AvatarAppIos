//
//  ConfirmationCodeViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 17.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import InputMask

class ConfirmationCodeViewController: UIViewController, MaskedTextFieldDelegateListener {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var listener: MaskedTextFieldDelegate!
    @IBOutlet weak var enteredCodeField: UITextField!
    @IBOutlet private weak var nextStepButton: UIButton!
    @IBOutlet weak var enteredEmail: UILabel!
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        if emailFromPreviousView != "" && didCompleteEnteringCode {
            Authorization.confirmCode(email: emailFromPreviousView, code: codeToCheck) { (serverResult) in
                switch serverResult {
                case .error(let error):
                    print("API Error \(error)")
                    //Error alert
                case .results(let result):
                    if result == "success" {
                        self.statusLabel.setLabelWithAnimation(in: self.view, hidden: false, startDelay: 0)
                        self.nextStepButton.isEnabled = false
                        self.statusLabel.setLabelWithAnimation(in: self.view, hidden: true, startDelay: 0.6)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            if user.userType! == "Star" {
                                self.performSegue(withIdentifier: "Show StarStartScreen", sender: nil)
                            }else{
                                self.performSegue(withIdentifier: "Show ProducerStartScreen", sender: nil)
                            }
                        }
                        self.nextStepButton.isEnabled = true
                    } else {
                        //SHOW INCORRECT CODE ALERT
                        self.showEnteredCodeWarningAlert(with: "Неверный код")
                        self.enteredCodeField.text = ""
                    }
                    
                }
            }
        } else {
            showEnteredCodeWarningAlert(with: "Некорректный ввод кода")
            enteredCodeField.text = ""
        }
    }
    @IBAction func wrongEmailButtonPressed(_ sender: Any) {
        showReEnteringEmailAlert()
    }
    @IBAction func didntGetCodeButtonPressed(_ sender: Any) {
        showReSendingCodeAlert()
        enteredCodeField.text = ""
    }
    
    var codeToCheck = ""
    var didCompleteEnteringCode = false
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        //print(value)
        codeToCheck = value
        didCompleteEnteringCode = complete
        if !(didCompleteEnteringCode || textField.text == "") {
            enteredCodeField.text = codeToCheck + " _".times(6 - codeToCheck.count)
            enteredCodeField.setCursorPosition(to: value.count)
        }
    }
    
    var emailFromPreviousView = "sdf"
    override func viewDidLoad() {
        super.viewDidLoad()
        enteredEmail.text = emailFromPreviousView
        self.enteredCodeField.delegate = listener
        nextStepButton.configureBackgroundColors()
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

//MARK:- Hide the keyboard by pressing the return key
extension ConfirmationCodeViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
