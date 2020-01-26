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
    
    @IBOutlet weak var listener: MaskedTextFieldDelegate!
    @IBOutlet weak var enteredCodeLabel: UITextField!
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
                        self.showSuccessEmailConfirmationAlert()
                        self.performSegue(withIdentifier: "Show StarStartScreen", sender: nil)
                        //perform some segue here
                    }
                    
                }
            }
        } else {
            showEnteredCodeWarningAlert(with: "Некорректный ввод кода")
        }
    }
    @IBAction func wrongEmailButtonPressed(_ sender: Any) {
        showReEnteringEmailAlert()
    }
    @IBAction func didntGetCodeButtonPressed(_ sender: Any) {
        showReSendingCodeAlert()
        enteredCodeLabel.text = ""
    }
    
    var codeToCheck = ""
    var didCompleteEnteringCode = false
    open func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        //print(value)
        codeToCheck = value
        didCompleteEnteringCode = complete
        if !(didCompleteEnteringCode || textField.text == "") {
            enteredCodeLabel.text = codeToCheck + " _".times(6 - codeToCheck.count)
            enteredCodeLabel.setCursorPosition(to: value.count)
        }
    }
    
    var emailFromPreviousView = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        enteredEmail.text = emailFromPreviousView
        self.enteredCodeLabel.delegate = listener
        nextStepButton.setBackgroundColor(.systemBlue, forState: .highlighted)
        //nextStepButton.layer.cornerRadius = 8  -- is set in storyboard
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
