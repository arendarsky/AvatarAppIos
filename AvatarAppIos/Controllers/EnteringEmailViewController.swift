//
//  EnteringEmailViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class EnteringEmailViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet private weak var nextStepButton: UIButton!
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show Confirmation VC", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextStepButton.layer.cornerRadius = 8
    }
    //hello 
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Confirmation VC" {
            let destinationVC = segue.destination as! ConfirmationCodeViewController
            let button = sender as! UIButton
        }
    }
    */
}
