//
//  AlertExtensions.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import UIKit

//MARK:- ALERT EXTENSIONS
//MARK:- Show warning alert about incorrect e-mail
public extension UIViewController {
    func showEmailWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, введите почту заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
//MARK:- Show warning alert about incorrect Name input
    func showNameWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, введите имя заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }

//MARK:- Show warning alert about incorrect video length
    func showLengthWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, выберите фрагмент вашего видео заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }

//MARK:- Warning Alert - Incorrect Confirmation Code Entered
    func showEnteredCodeWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, введите код подтверждения заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    
//MARK:- Show Alert Offering to Re-Enter Email
    func showReEnteringEmailAlert() {
        let alert = UIAlertController(title: "Ввели неправильный e-mail?", message: "Введите другой адрес для получения кода проверки", preferredStyle: .alert)
        let cancelBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        let okBtn = UIAlertAction(title: "OK", style: .cancel) { (action) in
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            }
        }
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
    }
    
//MARK:- Show Alert Offering to Re-Send Confirmation Code
    func showReSendingCodeAlert(){
        let alert = UIAlertController(title: "Отправить код еще раз?", message: "Отправим код проверки на введенный адрес еще раз", preferredStyle: .alert)
        let cancelBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        let okBtn = UIAlertAction(title: "Да", style: .cancel) { (action) in
            //SEND CODE OFFER FROM HERE
        }
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
    }
    
//MARK:- Email-Confirmed-Successfully Alert
    func showSuccessEmailConfirmationAlert(){
        let alert = UIAlertController(title: "Почта успешно подтверждена", message: "Дальше что-то будет", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
//MARK:- Error Connecting To Server Alert
    func showErrorConnectingToServerAlert(title: String = "Не удалось связаться с сервером", message: String = "Повторите попытку позже"){
        let alert = UIAlertController(title: "Не удалось связаться с сервером", message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
}

