//
//  ProducerStartScreenVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 20.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ProducerStartScreenVC: UIViewController {
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var nextStepButton: UIButton!
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        if inputName.text != "" {
            producerName = inputName.text!
            user.name = producerName
            performSegue(withIdentifier: "Show ProducerStartReadyVC", sender: sender)
        }
        else{
            showNameWarningAlert(with: "Некорректное имя")
            inputName.text = ""
        }
    }
    
    public var producerName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputName.delegate = self
        nextStepButton.configureBackgroundColors()
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

//MARK:- Hide the keyboard by pressing the return key
extension ProducerStartScreenVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
