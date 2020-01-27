//
//  EnteringEmailViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class EnteringEmailViewController: UIViewController {

    @IBOutlet weak var sendingCodeNotification: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet private weak var nextStepButton: UIButton!
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        if emailField.text == "" {
            showEmailWarningAlert(with: "Пустое поле почты")
        }
        else if !(emailField.text!.contains("@") && emailField.text!.contains(".")) {
            showEmailWarningAlert(with: "Некорректный адрес")
            emailField.text = ""
        }
        else {
            let a = emailField.text!.firstIndexOf(char: "@")!
            let b = emailField.text!.lastIndexOf(char: ".")!
            if !(a > 0 && a + 1 < b) {
                showEmailWarningAlert(with: "Некорректный адрес")
                emailField.text = ""
            }
            else {
                sendingCodeNotification.setLabelWithAnimation(in: self.view, hidden: false, delay: 0.5)
                sendingCodeNotification.setLabelWithAnimation(in: self.view, hidden: true, delay: 2.0)
                
                Authorization.sendEmail(email: emailField.text!){ serverResult in
                    switch serverResult {
                    case .error(let error) :
                        print("API Error: \(error)")
                        //show server error alert
                    case .results(let results):
                        print(results)
                        self.performSegue(withIdentifier: "Show Confirmation VC", sender: sender)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
    
        nextStepButton.configureBackgroundColors()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Confirmation VC" {
            let destinationVC = segue.destination as! ConfirmationCodeViewController
            destinationVC.emailFromPreviousView = emailField.text!
        }
    }
    
//Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

//MARK:- Hide the keyboard by pressing the return key
extension EnteringEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
