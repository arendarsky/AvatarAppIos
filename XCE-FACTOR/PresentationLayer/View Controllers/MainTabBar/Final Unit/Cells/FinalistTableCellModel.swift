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
    
    /// Иконка профиля финалиста
    let image: UIImage?
    
    /// Имя и Фамилия финалиста
    let name: String
    
    /// Отдан ли голос этому участнику
    let voted: Bool
}
