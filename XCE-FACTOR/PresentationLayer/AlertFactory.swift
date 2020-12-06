//
//  AlertFactory.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.12.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit.UIAlert

enum AlertTypes {
    case mailNotConfirmed
    case incorrectPassword
    case incorrectEmailAdress
    case notAllFieldsFilled
    case incorrectAdress
    case incorrectEmailOrPassword
    case letterNotSend
    case enterPassword
    case letterSend
    case emptyPasswordFields
    case emptyPasswordField
    case failedChangePassword
    case enterIncorrectPassword
    case failedSendLetter
    case accountAlreadyExists
}

protocol AlertFactoryProtocol {
    typealias Completion = (String) -> Void
    /// Показать обычный алерт
    /// - Parameter type: Тип алерта
    func showAlert(type: AlertTypes)

    func showResetPasswordAlert(email: String?, allowsEditing: Bool, completion: @escaping Completion)
}

final class AlertFactory {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

// MARK: - AlertFactoryProtocol

extension AlertFactory: AlertFactoryProtocol{
    
    func showAlert(type: AlertTypes) {
        let title: String
        let message: String
        let tintColor: UIColor = .white
        var style: UIAlertAction.Style = .default

        switch type {
        case .mailNotConfirmed:
            title = "Почта пока еще не подтверждена"
            message = "Перейдите по ссылке в письме или запросите письмо еще раз"
        case .incorrectPassword:
            title = "Неверный пароль"
            message = "Почта успешно подтверждена, однако пароль неверный. Пожалуйста, введите пароль ещё раз."
        case .incorrectEmailAdress:
            title = "Некорректный адрес почты"
            message = ""
        case .notAllFieldsFilled:
            title = "Заполнены не все необходимые поля"
            message = "Пожалуйста, введите данные еще раз"
        case .incorrectAdress:
            title = "Некорректный адрес"
            message = "Пожалуйста, введите почту еще раз"
        case .incorrectEmailOrPassword:
            title = "Неверный e-mail или пароль"
            message = "Пожалуйста, введите данные снова"
        case .letterNotSend:
            title = "Не удалось отправить письмо"
            message = "Проверьте правильность ввода адреса почты и подключение к интернету"
            style = .cancel
        case .enterPassword:
            title = "Введите пароль"
            message = ""
        case .letterSend:
            title = "Письмо отправлено"
            message = "Вам на почту было отправлено письмо с дальнейшими инструкциями по сбросу пароля"
        case .emptyPasswordFields:
            title = "Пустое поле пароля"
            message = "Пожалуйста, введите старый и новый пароли"
        case .emptyPasswordField:
            title = "Пустое поле пароля"
            message = "Пожалуйста, введите новый пароль"
        case .failedChangePassword:
            title = "Не удалось изменить пароль"
            message = "Проверьте подключение к интернету и попробуйте снова"
        case .enterIncorrectPassword:
            title = "Введён неверный пароль"
            message = "Введите корректный пароль и попробуйте снова"
        case .failedSendLetter:
            title = "Не удалось отправить письмо"
            message = "Проверьте правильность ввода адреса почты и подключение к интернету"
            style = .cancel
        case .accountAlreadyExists:
            title = "Такой аккаунт уже существует"
            message = "Выполните вход в аккаунт или введите другие данные"
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: style, handler: nil)

        alert.view.tintColor = tintColor
        alert.addAction(okButton)

        viewController?.present(alert, animated: true)
    }

    func showResetPasswordAlert(email: String?, allowsEditing: Bool, completion: @escaping Completion) {
        let title = "Забыли пароль?"
        let message = "Отправим письмо для сброса пароля на этот адрес:"
        let sendButtonTitle = "Отправить"
        let cancelButtonTitle = "Отмена"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        let sendButton = UIAlertAction(title: sendButtonTitle, style: .default) { _ in
            let enteredEmail = alert.textFields?.first?.text ?? email ?? "null"
            completion(enteredEmail)
        }

        if #available(iOS 13.0, *) {
            alert.view.tintColor = .label
        } else {
            alert.view.tintColor = .white
        }

        alert.addAction(cancelButton)
        alert.addAction(sendButton)
    
        alert.addTextField { textField in
            textField.placeholder = "example@mailbox.net"
            textField.text = email
            textField.keyboardType = .emailAddress
            textField.clearButtonMode = allowsEditing ? .always : .never
            textField.textContentType = .username
            textField.textAlignment = .center
            textField.isEnabled = allowsEditing
            
            if #available(iOS 13.0, *) {} else {
                textField.setPlaceholderTextColor(UIColor.black.withAlphaComponent(0.4))
                textField.textColor = .black
            }
        }

        viewController?.present(alert, animated: true)
    }
}
