//
//  StarStartScreenVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 20.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class StarStartScreenVC: UIViewController {
    @IBOutlet private weak var inputName: UITextField!
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        if inputName.text != "" {
            starName = inputName.text!
            performSegue(withIdentifier: "Show VideoUploadVC", sender: sender)
            
        }
        else{
            showNameWarningAlert(with: "Некорректное имя")
            inputName.text = ""
        }
    }
    
    var starName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputName.delegate = self

    }
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

//MARK:- Hide the keyboard by pressing the return key
extension StarStartScreenVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
