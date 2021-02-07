//
//  BattleModel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 29.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

struct BattleModel: Decodable {
    var id: Int
    var endDate: String
    var winnersNumber: Int?
    var totalVotesNumber: Int?
    var battleParticipants: [BattleParticipant]?
}
