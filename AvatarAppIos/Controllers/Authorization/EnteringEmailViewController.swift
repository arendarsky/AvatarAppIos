//
//  EnteringEmailViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class EnteringEmailViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sendingCodeNotification: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet private weak var nextStepButton: UIButton!
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        //MARK:- Validation of mail input
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
                //MARK:- Sending E-mail to the Server
                user.email = emailField.text!
                sendingCodeNotification.setLabelWithAnimation(in: self.view, hidden: false, startDelay: 0)
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                var flag = true
                Authorization.sendEmail(email: emailField.text!) { (serverResult) in
                    switch serverResult {
                    case .error(let error):
                        if error.localizedDescription == "serverError" {
                            self.showErrorConnectingToServerAlert(message: "Повторите попытку позже")
                        }else{
                            flag = false
                            print("API Error: \(error)")
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.sendingCodeNotification.isHidden = true
                            self.showErrorConnectingToServerAlert(message: "Проверьте подключение к интернету и попробуйте снова")
                        }
                    case .results(let results):
                        print(results)
                        self.sendingCodeNotification.isHidden = true
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.performSegue(withIdentifier: "Show Confirmation VC", sender: sender)
                    }
                }
                ///This is a segue w/o waiting for response from the server
                if flag {
                    //self.sendingCodeNotification.isHidden = true
                    //self.performSegue(withIdentifier: "Show Confirmation VC", sender: sender)
                }

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
        activityIndicator.isHidden = true
        nextStepButton.configureHighlightedColors()
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
    
    //MARK:- Delete All Spaces
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.contains(" "))! {
            textField.text?.removeAll(where: { (char) -> Bool in
                char == " "
            })
        }
    }
}
