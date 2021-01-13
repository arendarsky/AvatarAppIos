//
//  ProfileRequestModel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 06.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

/// Модель запроса для смена данных профиля
struct ProfileRequestModel {
    /// Имя профиля
    let name: String
    /// Описание профиля
    let description: String
    /// Привязанный инстаграмм аккаунт к профилю
    let instagramLogin: String
}
