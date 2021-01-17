//
//  MessageContentVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 23.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

final class MessageContentVC: XceFactorViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var messageField: UITextField!

    // MARK: - Private Properties

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private var alertFactory: AlertFactoryProtocol?

    // MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Инициализирвоать в билдере, при переписи на MVP поправить:
        alertFactory = AlertFactory(viewController: self)

        messageField.delegate = self
    }

    // MARK: - IBActions
    // TODO: IBActions -> Actions
    @IBAction func sendButtonPressed(_ sender: Any) {
        alertFactory?.showAlert(type: .optionNotAvailable) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        print("cancel pressed")
    }

    // MARK: - Overrides
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension MessageContentVC: UITextFieldDelegate {

    /// Hide the keyboard by pressing the return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

}
