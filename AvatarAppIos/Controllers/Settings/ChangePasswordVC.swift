//
//  ChangePasswordVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 21.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ChangePasswordVC: UIViewController {

    //MARK:- Properties
    @IBOutlet weak var oldPasswordView: UIView!
    @IBOutlet weak var oldPasswordLabel: UILabel!
    @IBOutlet weak var oldPasswordField: UITextField!
    
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var newPasswordLabel: UILabel!
    @IBOutlet weak var newPasswordField: UITextField!
    
    @IBOutlet weak var changeSettingsNavItem: UINavigationItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    let activityIndicator = UIActivityIndicatorView()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        
    }
    
    //MARK:- Cancel Button Pressed
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Save Button Pressed
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let oldPassword = oldPasswordField.text else {
            showIncorrectUserInputAlert(title: "Неверный пароль", message: "")
            return
        }
        guard let newPassword = newPasswordField.text else {
            showIncorrectUserInputAlert(title: "Введите новый пароль", message: "")
            return
        }
        
        activityIndicator.enableInNavBar(of: changeSettingsNavItem)
        Profile.changePassword(oldPassword: oldPassword, newPassword: newPassword) { (serverResult) in
            self.activityIndicator.disableInNavBar(of: self.changeSettingsNavItem, replaceWithButton: self.saveButton)
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showIncorrectUserInputAlert(title: "Не удалось изменить пароль", message: "Проверьте подключение к интернету и попробуйте снова")
            case .results(let isCorrect):
                if isCorrect {
                    //self.activityIndicator.disableInNavBar(of: self.changeSettingsNavItem, replaceWithButton: self.saveButton)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showIncorrectUserInputAlert(title: "Введён неверный пароль", message: "Введите корректный пароль и попробуйте снова")
                }
            }
        }
    }
    
}

extension ChangePasswordVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if newPasswordField.text?.count == 0 {
            newPasswordView.borderWidthV = 1.0
            newPasswordView.borderColorV = .systemRed
        } else {
            newPasswordView.borderWidthV = 0.0
        }
        
        if oldPasswordField.text?.count == 0 {
            oldPasswordView.borderWidthV = 1.0
            oldPasswordView.borderColorV = .systemRed
        }
    }
}

private extension ChangePasswordVC {
    //MARK:- Configurations
    private func configureViews() {
        //let cornerRadius: CGFloat = 8.0
        let padding: CGFloat = 10.0
        
        oldPasswordField.addPadding(.both(padding))
        newPasswordField.addPadding(.both(padding))
        
        oldPasswordLabel.addTapGestureRecognizer {
            self.oldPasswordField.becomeFirstResponder()
        }
        newPasswordLabel.addTapGestureRecognizer {
            self.newPasswordField.becomeFirstResponder()
        }
    }
}
