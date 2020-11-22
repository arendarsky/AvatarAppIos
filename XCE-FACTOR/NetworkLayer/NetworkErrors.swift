//
//  NetworkError.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 20.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

/// Сетевые ошибки
enum NetworkErrors: Error {
    case unconfirmed // Пользователь не подтвердил свой email
    case describing(Error) // Ошибка с описанием
    case wrondCredentials // Неверный логин или пароль
    case `default` // Дефолтная ошибка
}
