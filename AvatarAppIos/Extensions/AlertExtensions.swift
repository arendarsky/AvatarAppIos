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
///
///

public extension UIViewController {
    
    /// this alert unites meaning of 3 alert funcs going after it. They will be taken out of use soon ⬇️
    //MARK:- Incorrect User Input Alert
    /// Use this func when some fields were not filled in a proper way. There are default values for title and message fields.
    func showIncorrectUserInputAlert(title: String = "Введены некорректные данные", message: String = "Пожалуйста, заполните необходимые поля еще раз", tintColor: UIColor = .white) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        
        present(alert, animated: true, completion: nil)
    }

//MARK:- ❗️Do not use these 3 alerts, they will be taken out of use soon ⬇️
    // Show warning alert about incorrect e-mail
    func showEmailWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, введите почту заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
// Show warning alert about incorrect Name input
    func showNameWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, введите имя заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    // Warning Alert - Incorrect Confirmation Code Entered
    func showEnteredCodeWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, введите код подтверждения заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
//MARK:- ❗️These 3 alerts will be taken out of use soon ⬆️
    
    

//MARK:- Show warning alert about incorrect video length
    func showVideoErrorAlert(with title: String, tintColor: UIColor = .white){
        let alert = UIAlertController(title: title, message: "Пожалуйста, выберите фрагмент вашего видео заново", preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    
//MARK:- Show Alert Offering to Re-Enter Email
    func showReEnteringEmailAlert(okHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "Ввели неправильный e-mail?", message: "Введите другой адрес для получения кода проверки", preferredStyle: .alert)
        alert.view.tintColor = .label
        
        let cancelBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: okHandler)
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
    }
    
//MARK:- Show Alert Offering to Re-Send Confirmation Code
    func showReSendingEmailAlert(okHandler: ((UIAlertAction) -> Void)?){
        let alert = UIAlertController(title: "Отправить письмо еще раз?", message: "Отправим письмо для подтверждения на введенный адрес еще раз", preferredStyle: .alert)
        alert.view.tintColor = .label
        
        let cancelBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        let okBtn = UIAlertAction(title: "Да", style: .cancel, handler: okHandler)
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
    func showErrorConnectingToServerAlert(title: String = "Не удалось связаться с сервером", message: String = "Повторите попытку позже", tintColor: UIColor = .white){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    
//MARK:- Feature Not Available Now Alert
    func showFeatureNotAvailableNowAlert(title: String = "Эта опция сейчас недоступна", message: String = "Ожидайте следующий релиз :)", shouldAddCancelButton: Bool = false, tintColor: UIColor = .white, okBtnhandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "ОК", style: .cancel, handler: okBtnhandler)
        alert.addAction(okBtn)
        
        if shouldAddCancelButton {
            let cnclBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
            alert.addAction(cnclBtn)
        }
        
        present(alert, animated: true, completion: nil)

    }
    
    //MARK:- Successful Video Upload Alert
    func showVideoUploadSuccessAlert(title: String = "Видео успешно загружено на сервер", message: String = "Оно появится в кастинге после проверки", tintColor: UIColor = .white, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: handler)
        alert.addAction(okBtn)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Pick Media Alert
    func showMediaPickAlert(mediaTypes: [CFString], delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, allowsEditing: Bool = false) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        let cameraBtn = UIAlertAction(title: "Снять на камеру", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: delegate, mediaTypes: mediaTypes, sourceType: .camera, allowsEditing: allowsEditing)
        }
        let galleryButton = UIAlertAction(title: "Выбрать из фотопленки", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: delegate, mediaTypes: mediaTypes, sourceType: .savedPhotosAlbum, allowsEditing: allowsEditing)
        }
        let cancelBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(cameraBtn)
        alert.addAction(galleryButton)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Exit Account Alert
    func showExitAccountAlert(title: String = "Выйти из аккаунта?", message: String = "Это завершит текущую сессию пользователя", tintColor: UIColor = .white, okHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "Да", style: .default, handler: okHandler)

        let cancelBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true, completion: nil)
    }
}

