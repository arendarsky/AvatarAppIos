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
}

protocol AlertFactoryProtocol {
    func showAlert(type: AlertTypes)
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

        switch type {
        case .mailNotConfirmed:
            title = "Почта пока еще не подтверждена"
            message = "Перейдите по ссылке в письме или запросите письмо еще раз"
        case .incorrectPassword:
            title = "Неверный пароль"
            message = "Почта успешно подтверждена, однако пароль неверный. Пожалуйста, введите пароль ещё раз."
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)

        alert.view.tintColor = tintColor
        alert.addAction(okBtn)

        viewController?.present(alert, animated: true, completion: nil)
    }
}
