//
//  MessageViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 23.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    @IBOutlet weak var messageField: UITextField!
    //weak var vc: CastingViewController?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        messageField.delegate = self
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        print("cancel pressed")
        if let navigationController = self.navigationController {
            //vc?.hideGrayView()
            navigationController.dismiss(animated: true, completion: nil)
        }
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

//MARK:- Hide the keyboard by pressing the return key
extension MessageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}
