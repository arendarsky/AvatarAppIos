//
//  StoriesCellModel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 11.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit.UIImage

enum StroriesCellType {
    case likes(number: Int?)
    case percent(totalVotesNumber: Int?, votesNumber: Int?, liked: Bool?)
}

struct StoriesCellModel {
    /// Имя профиля
    var name: String

    /// Тип ячейки сторисов
    var stroriesCellType: StroriesCellType

    /// Фото профиля
    var profileImage: UIImage
}
