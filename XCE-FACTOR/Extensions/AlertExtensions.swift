//
//  AvatarAppIos
//
//  Created by Владислав on 25.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

public extension UIViewController {

    func showErrorConnectingToServerAlert(title: String = "Не удалось связаться с сервером", message: String = "Повторите попытку позже", tintColor: UIColor = .white){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }

////MARK:- Alert Offering to Re-Enter Email
//    func showReEnteringEmailAlert(okHandler: ((UIAlertAction) -> Void)?) {
//        let alert = UIAlertController(title: "Ввели неправильный e-mail?", message: "Введите другой адрес для получения кода проверки", preferredStyle: .alert)
//        if #available(iOS 13.0, *) {
//            alert.view.tintColor = .label
//        } else {
//            alert.view.tintColor = .white
//        }
//
//        let cancelBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
//        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: okHandler)
//        alert.addAction(okBtn)
//        alert.addAction(cancelBtn)
//        present(alert, animated: true, completion: nil)
//    }
    
////MARK:- Alert Offering to Re-Send Confirmation Code
//    func showReSendingEmailAlert(okHandler: ((UIAlertAction) -> Void)?){
//        let alert = UIAlertController(title: "Отправить письмо еще раз?", message: "Отправим письмо для подтверждения на введенный адрес еще раз. Проверьте также папку \"Спам\"", preferredStyle: .alert)
//        if #available(iOS 13.0, *) {
//            alert.view.tintColor = .label
//        } else {
//            alert.view.tintColor = .white
//        }
//
//        let cancelBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
//        let okBtn = UIAlertAction(title: "Да", style: .cancel, handler: okHandler)
//        alert.addAction(okBtn)
//        alert.addAction(cancelBtn)
//        present(alert, animated: true, completion: nil)
//    }

//    func showFeatureNotAvailableNowAlert(title: String = "Эта опция сейчас недоступна", message: String = "Ожидайте следующий релиз :)", shouldAddCancelButton: Bool = false, tintColor: UIColor = .white, okBtnhandler: ((UIAlertAction) -> Void)? = nil) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.view.tintColor = tintColor
//        let okBtn = UIAlertAction(title: "ОК", style: .cancel, handler: okBtnhandler)
//        alert.addAction(okBtn)
//
//        if shouldAddCancelButton {
//            let cnclBtn = UIAlertAction(title: "Отмена", style: .default, handler: nil)
//            alert.addAction(cnclBtn)
//        }
//
//        present(alert, animated: true, completion: nil)
//
//    }
    
//    enum VideoUploadType {
//        case uploadingVideo(String?)
//        case intervalEditing
//    }
    
//    func showVideoUploadSuccessAlert(_ messageType: VideoUploadType = .uploadingVideo(nil), tintColor: UIColor = .white, handler: ((UIAlertAction) -> Void)? = nil) {
//        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
//        alert.view.tintColor = tintColor
//        switch messageType {
//        case .intervalEditing:
//            alert.title = "Интервал успешно изменен"
//            alert.message = ""
//        case .uploadingVideo(let message):
//            alert.title = "Видео успешно загружено на сервер"
//            alert.message = message ?? "Оно появится в Кастинге после проверки"
//        }
//
//        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: handler)
//        alert.addAction(okBtn)
//
//        present(alert, animated: true, completion: nil)
//    }
    
    //MARK:- IMGPicker Alert
    func showMediaPickAlert(mediaTypes: [CFString], delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, allowsEditing: Bool = false, title: String? = nil, modalPresentationStyle: UIModalPresentationStyle = .overFullScreen) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        let cameraBtn = UIAlertAction(title: "Снять на камеру", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: delegate, mediaTypes: mediaTypes, sourceType: .camera, allowsEditing: allowsEditing, modalPresentationStyle: modalPresentationStyle)
        }
        let galleryButton = UIAlertAction(title: "Выбрать из фотопленки", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: delegate, mediaTypes: mediaTypes, sourceType: .photoLibrary, allowsEditing: allowsEditing, modalPresentationStyle: modalPresentationStyle)
        }
        let cancelBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(cameraBtn)
        alert.addAction(galleryButton)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Exit Account Alert
    func confirmActionAlert(title: String, message: String, tintColor: UIColor = .white, cancelTitle: String = "Отмена", okHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let okBtn = UIAlertAction(title: "Да", style: .default, handler: okHandler)
        let cancelBtn = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true, completion: nil)
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
    
    //MARK:- Show Alert With 2 Buttons
    ///All messages are customizable and both buttons may be handled (or not)
    func showTwoOptionsAlert(title: String, message: String, tintColor: UIColor = .white, option1Title: String, handler1: ((UIAlertAction) -> Void)?, option2Title: String, handler2: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let option1 = UIAlertAction(title: option1Title, style: .default, handler: handler1)
        let option2 = UIAlertAction(title: option2Title, style: .default, handler: handler2)
        
        alert.addAction(option1)
        alert.addAction(option2)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Show Action Sheet With Configurable Option
    ///Cancel button is set by default
    func showActionSheetWithOptions(title: String?, buttons: [UIAlertAction], buttonTextAligment: CATextLayerAlignmentMode = .center, cancelTitle: String = "Отмена", tintColor: UIColor = .white) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = tintColor
        
        buttons.forEach { (button) in
            //button.titleAlignment = buttonTextAligment
            alert.addAction(button)
        }
        
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Text Field Alert
    func showAlertWithTextField(title: String, message: String,
                                textFieldText: String? = nil, placeholder: String? = nil,
                                contentType: UITextContentType = .nickname, textAlignment: NSTextAlignment = .left,
                                tintColor: UIColor = .label,
                                cancelTitle: String = "Отмена", cancelHandler: ((UIAlertAction) -> Void)? = nil,
                                okTitle: String = "OK", okHandler: ((_ textFieldText: String) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = tintColor
        let cancelBtn = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler)
        let okBtn = UIAlertAction(title: okTitle, style: .default) { (okAction) in
            let text = alert.textFields?.first?.text ?? ""
            okHandler?(text)
        }

        alert.addAction(cancelBtn)
        alert.addAction(okBtn)
        
        alert.addTextField { (field) in
            field.text = textFieldText
            field.placeholder = placeholder
            field.clearButtonMode = .always
            field.textContentType = contentType
            field.textAlignment = textAlignment
        }
        
        present(alert, animated: true, completion: nil)
    }
}


//MARK:- UIAlertAction
extension UIAlertAction {
    var actionImage: UIImage? {
        get {
            return self.value(forKey: "image") as? UIImage
        }
        
        set {
            self.setValue(newValue, forKey: "image")
        }
    }
    
    var titleAlignment: CATextLayerAlignmentMode? {
        get {
            return self.value(forKey: "titleTextAlignment") as? CATextLayerAlignmentMode
        }
        
        set {
            self.setValue(newValue, forKey: "titleTextAlignment")
        }
    }
    
    convenience init(title: String?, alignment: CATextLayerAlignmentMode = .center, image: UIImage?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) {
        self.init(title: title, style: style, handler: handler)
        self.actionImage = image
        //self.titleAlignment = alignment
    }
}
