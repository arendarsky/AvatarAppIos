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
    //@IBOutlet weak var enteredCodeField: UITextField!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    //var codeToCheck = ""
    //var didCompleteEnteringCode = false
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        configureViews()
        //self.enteredCodeField.delegate = listener
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK:- Wrong Email Button Pressed
    @IBAction func wrongEmailButtonPressed(_ sender: UIButton) {
        showReEnteringEmailAlert { (action) in
            //show registration vc
        }
    }
    
    //MARK:- Resend Confirm Button Pressed
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        showReSendingEmailAlert { (action) in
            Authentication.sendEmail(email: user.email) { (result) in
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
    func configureViews() {
        emailLabel.text = "example@gmail.com"
        doneButton.addGradient()
    }
}
