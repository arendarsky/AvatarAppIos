//
//  AlertFactory.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.12.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit.UIAlert

/// Типы заголовков алертов
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
    case logOut
    case cancelEditing
    case videoDeleteError
    case saveVideoError
    case saveNameError
    case loadPhotoError
    case connectionToServerError
    case connectionToServerErrorReconnect
    case descriptionIsTooLong
    case notAllowToCasting
    case videoRejectByModerator
    case enterIncorrectEmail
    case resendEmail
    case failShare
    case handleError
    case requestTimedOut
    case optionNotAvailable
    case intervalEditing
    case uploadingVideo
    case videoNotAdded
}

/// Протокол фабрикм по показу алертов
protocol AlertFactoryProtocol {

    typealias Completion = (String) -> Void

    typealias Action = ((UIAlertAction) -> Void)
    
    /// Показать обычный алерт
    /// - Parameter type: Тип алерта
    func showAlert(type: AlertTypes)
    
    /// Показать алерт с действием
    /// - Parameters:
    ///   - type: Тип алерта
    ///   - action: Действие при нажатии на кнопку согласия
    func showAlert(type: AlertTypes, action: Action?)

    /// Показать алерт с кастомным заголовком и текстом
    /// - Parameters:
    ///   - title: Заголовок
    ///   - message: Текст
    func showAlert(title: String?, message: String?)
    
    /// Показать алерт восстановления пароля
    /// - Parameters:
    ///   - email: Почта пользователя
    ///   - allowsEditing: Разрешено редактирование
    ///   - completion: Действие при нажатии на кнопку
    func showResetPasswordAlert(email: String?, allowsEditing: Bool, completion: @escaping Completion)
}

/// Фабрика по показу алертов
final class AlertFactory {

    // MARK: - Public Properties

    weak var viewController: UIViewController?

    // MARK: - Init

    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
}

// MARK: - AlertFactoryProtocol

extension AlertFactory: AlertFactoryProtocol {
    
    func showAlert(type: AlertTypes) {
        makeAlert(type: type, action: nil)
    }

    func showAlert(type: AlertTypes, action: Action?) {
        makeAlert(type: type, action: action)
    }

    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title ?? "", message: message ?? "", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)

        alert.view.tintColor = .white
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

// MARK: - Private Methods

private extension AlertFactory {
    func makeAlert(type: AlertTypes, action: Action?) {
        let title: String
        let message: String

        var okButtonTitle = "OK"
        var cancelButtonTitle = "Отмена"

        var hideSecondButton = false
        var tintColor: UIColor = .white
        var style: UIAlertAction.Style = .default
        var cancelStyle: UIAlertAction.Style = .cancel

        // TODO: Сделать фабрику текстов
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
        case .logOut:
            title = "Выйти из аккаунта?"
            message = "Это завершит текущую сессию пользователя"
            okButtonTitle = "Да"
        case .cancelEditing:
            title = "Отменить редактирование?"
            message = "При переходе на следующий экран внесённые изменения не сохранятся"
            okButtonTitle = "Да"
            cancelButtonTitle = "Нет"
        case .videoDeleteError:
            title = "Не удалось удалить видео в данный момент"
            message = "Обновите экран профиля и попробуйте снова."
            style = .cancel
        case .saveVideoError:
            title = "Не удалось сохранить новое описание"
            message = "Попробуйте еще раз."
            style = .cancel
        case .saveNameError:
            title = "Не удалось сохранить новое имя"
            message = "Проверьте подключение к интернету и попробуйте еще раз"
            style = .cancel
        case .loadPhotoError:
            title = "Не удалось загрузить фото"
            message = "Обновите экран профиля и попробуйте еще раз"
            style = .cancel
        case .connectionToServerError:
            title = "Не удалось связаться с сервером"
            message = "Повторите попытку позже"
            style = .cancel
        case .descriptionIsTooLong:
            title = "Описание слишком длинное"
            message = ""
        case .notAllowToCasting:
            title = "Видео пока нельзя отправить в Кастинг"
            message = "Оно ещё не прошло модерацию."
        case .videoRejectByModerator:
            title = "Видео не прошло модерацию, его нельзя отправлять в Кастинг"
            message = "Вы можете удалить это видео и загрузить новое"
        case .enterIncorrectEmail:
            title = "Ввели неправильный e-mail?"
            message = "Введите другой адрес для получения кода проверки"
            style = .cancel
            cancelStyle = .default
            if #available(iOS 13.0, *) {
                tintColor = .label
            } else {
                tintColor = .white
            }
        case .resendEmail:
            okButtonTitle = "Да"
            title = "Отправить письмо еще раз?"
            message = "Отправим письмо для подтверждения на введенный адрес еще раз. Проверьте также папку \"Спам\""
            style = .cancel
            cancelStyle = .default
            if #available(iOS 13.0, *) {
                tintColor = .label
            } else {
                tintColor = .white
            }
        case .failShare:
            title = "Не удалось поделиться"
            message = "Не удалось связаться с сервером для отправки видео в Instagram. Попробуйте поделиться ещё раз"
            style = .cancel
        case .connectionToServerErrorReconnect:
            title = "Не удалось связаться с сервером"
            message = "Проверьте подключение к интернету и попробуйте еще раз"
        case .handleError:
            title = "Произошла ошибка"
            message = "Поробуйте загрузить еще раз"
        case .requestTimedOut:
            title = "Не удалось связаться с сервером"
            message = "Истекло время ожидания запроса. Повторите попытку позже"
        case .optionNotAvailable:
            title = "Эта опция сейчас недоступна"
            message = "Ожидайте следующий релиз :)"
            style = .cancel
            hideSecondButton = true
        case .intervalEditing:
            title = "Интервал успешно изменен"
            message = ""
        case .uploadingVideo:
            title = "Видео успешно загружено на сервер"
            message = "Оно появится в Кастинге после проверки"
            style = .cancel
        case .videoNotAdded:
            title = "Видео не добавлено"
            message = "Пожалуйста, выберите Ваш фрагмент заново"
            style = .cancel
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: okButtonTitle, style: style, handler: action)

        alert.view.tintColor = tintColor
        alert.addAction(okButton)

        if let _ = action, !hideSecondButton {
            let cancelButton = UIAlertAction(title: cancelButtonTitle, style: cancelStyle, handler: nil)
            alert.addAction(cancelButton)
        }

        viewController?.present(alert, animated: true)
    }
}
