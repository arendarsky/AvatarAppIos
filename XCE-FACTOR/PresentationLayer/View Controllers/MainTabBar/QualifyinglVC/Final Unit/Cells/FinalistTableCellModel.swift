//
//  FinalistTableCellModel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

/// ViewModel ячейки финалиста
struct FinalistTableCellModel {
    
    /// Порядковый номер / индификатор
    let id: Int
    
    /// Иконка профиля финалиста
    var image: UIImage?
    
    /// Имя и Фамилия финалиста
    let name: String
    
    /// Отдан ли голос этому участнику
    var voted: Bool
    
    /// Доступна ли для нажатия кнопка
    var isEnabled: Bool = true
}