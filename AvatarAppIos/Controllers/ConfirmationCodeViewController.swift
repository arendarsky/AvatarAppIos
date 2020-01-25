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
        //nothing for now
    }
    @IBAction func wrongEmailButtonPressed(_ sender: Any) {
        showReEnteringEmailAlert()
    }
    @IBAction func didntGetCodeButtonPressed(_ sender: Any) {
         showReSendingCodeAlert()
    }
    
    open func textField(
        _ textField: UITextField,
        didFillMandatoryCharacters complete: Bool,
        didExtractValue value: String
    ) {
        print(value)
    }
    
    var emailFromPreviousView = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        enteredEmail.text = emailFromPreviousView
        self.enteredCodeLabel.delegate = listener
        
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
