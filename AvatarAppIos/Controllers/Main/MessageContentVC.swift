//
//  MessageContentVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 23.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class MessageContentVC: XceFactorViewController {
    
    @IBOutlet weak var messageField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        messageField.delegate = self
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        showFeatureNotAvailableNowAlert() { (action) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        print("cancel pressed")
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

//MARK:- Hide the keyboard by pressing the return key
extension MessageContentVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}
