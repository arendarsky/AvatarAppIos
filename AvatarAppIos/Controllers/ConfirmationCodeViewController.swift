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
    
    let emailFromPreviousView = "prostopochta@gmail.com"
    override func viewDidLoad() {
        super.viewDidLoad()
        nextStepButton.layer.cornerRadius = 8
        enteredEmail.text = emailFromPreviousView
    }
}
