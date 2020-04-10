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
    func showIncorrectUserInputAlert(title: String = "Введены некорректные данные", message: String = "Пожалуйста, заполните необходимые поля еще раз", tintColor: UIColor = .white, okHandler: ((UIAlertAction) -> Void)? = nil) {
        
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
    
    

//MARK:- Warning alert about incorrect video length
    func showVideoErrorAlert(with title: String, tintColor: UIColor = .white){
        let alert = UIAlertController(title: title, message: "Пожалуйста, выберите фрагмент вашего видео заново", preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
    
    
//MARK:- Alert Offering to Re-Enter Email
    func showReEnteringEmailAlert(okHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "Ввели неправильный e-mail?", message: "Введите другой адрес для получения кода проверки", preferredStyle: .alert)
        if #available(iOS 13.0, *) {
            alert.view.tintColor = .label
        } else {
            alert.view.tintColor = .white
        }
        
        let cancelBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: okHandler)
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        present(alert, animated: true, completion: nil)
    }
    
//MARK:- Alert Offering to Re-Send Confirmation Code
    func showReSendingEmailAlert(okHandler: ((UIAlertAction) -> Void)?){
        let alert = UIAlertController(title: "Отправить письмо еще раз?", message: "Отправим письмо для подтверждения на введенный адрес еще раз. Проверьте также папку 'Спам'.", preferredStyle: .alert)
        if #available(iOS 13.0, *) {
            alert.view.tintColor = .label
        } else {
            alert.view.tintColor = .white
        }
        
        let cancelBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        let okBtn = UIAlertAction(title: "Да", style: .cancel, handler: okHandler)
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
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
    
    enum VideoUploadType {
        case uploadingVideo
        case intervalEditing
    }
    
    //MARK:- Successful Video Upload Alert
    func showVideoUploadSuccessAlert(_ messageType: VideoUploadType = .uploadingVideo, tintColor: UIColor = .white, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.view.tintColor = tintColor
        switch messageType {
        case .intervalEditing:
            alert.title = "Интервал успешно изменен"
            alert.message = ""
        case .uploadingVideo:
            alert.title = "Видео успешно загружено на сервер"
            alert.message = "Оно появится в кастинге после проверки"
        }
        
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: handler)
        alert.addAction(okBtn)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- IMGPicker Alert
    func showMediaPickAlert(mediaTypes: [CFString], delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, allowsEditing: Bool = false, title: String? = nil) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        let cameraBtn = UIAlertAction(title: "Снять на камеру", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: delegate, mediaTypes: mediaTypes, sourceType: .camera, allowsEditing: allowsEditing)
        }
        let galleryButton = UIAlertAction(title: "Выбрать из фотопленки", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: delegate, mediaTypes: mediaTypes, sourceType: .photoLibrary, allowsEditing: allowsEditing)
        }
        let cancelBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(cameraBtn)
        alert.addAction(galleryButton)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Exit Account Alert
    func confirmActionAlert(title: String, message: String, tintColor: UIColor = .white, okHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "Да", style: .default, handler: okHandler)
        let cancelBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Forgot Password Alert
    func showResetPasswordAlert(email: String?, allowsEditing: Bool = true, title: String = "Забыли пароль?", message: String = "Отправим письмо для сброса пароля на этот адрес:", resetHandler: ((String) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelBtn = UIAlertAction(title: "Отмена", style: .cancel)
        let sendBtn = UIAlertAction(title: "Отправить", style: .default) { (action) in
            let enteredEmail = alert.textFields?.first?.text ?? email ?? "null"
            resetHandler?(enteredEmail)
        }
        
        if #available(iOS 13.0, *) {
            alert.view.tintColor = .label
        } else {
            alert.view.tintColor = .white
        }
        alert.addAction(cancelBtn)
        alert.addAction(sendBtn)
        alert.addTextField { (field) in
            field.placeholder = "example@mailbox.net"
            field.text = email
            field.keyboardType = .emailAddress
            field.clearButtonMode = allowsEditing ? .always : .never
            field.textContentType = .username
            field.textAlignment = .center
            field.isEnabled = allowsEditing
        }
        
        present(alert, animated: true)
    }
    
    //MARK:- Simple Alert
    /**A simple alert that gives some additional info,
     has only one  button which dismisses the alert controller by default.
     Use it for displaying supplementary messages e.g. successful url request.
     Default button title is 'OK', also any action can be assigned to the button with the closure.
     */
    func showSimpleAlert(title: String = "Успешно!", message: String = "", okButtonTitle: String = "OK", tintColor: UIColor = .white, okHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: okButtonTitle, style: .default, handler: okHandler)
        alert.addAction(okBtn)
        
        present(alert, animated: true, completion: nil)
    }
}
