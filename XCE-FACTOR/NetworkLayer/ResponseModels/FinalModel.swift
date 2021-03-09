//
//  FinalModel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 27.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

/// Модель Финала
struct FinalModel: Decodable {
    let videoUrl: String?
    let secondsUntilStart: Int
    let secondsUntilEnd: Int
    let winnersNumber: Int
    let finalists: [FinalistModel]
}
