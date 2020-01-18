//
//  ConfirmationCodeViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 17.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ConfirmationCodeViewController: UIViewController {

    @IBOutlet weak var enteredCodeLabel: UITextField!
    @IBOutlet private weak var nextStepButton: UIButton!
    @IBOutlet weak var enteredEmail: UILabel!
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
    }
    
    
    // Will be the buttons later:
    @IBOutlet weak var didntReceiveCodePressed: UILabel!
    @IBOutlet weak var wrongNumberPressed: UILabel!
    //--
    
    var emailFromPreviousView = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        nextStepButton.layer.cornerRadius = 8
        enteredEmail.text = emailFromPreviousView
        self.enteredCodeLabel.delegate = self
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

//MARK:- Hide the keyboard by pressing the return key
extension ConfirmationCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
