//
//  FinalistModel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 27.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

/// Модель финалиста
struct FinalistModel: Decodable {
    let id: Int
    var isVotedByUser: Bool
    let contestant: RatingProfile
}
