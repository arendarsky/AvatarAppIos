//
//  Battle.swift
//  XCE-FACTOR
//
//  Created by user on 20.09.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct BattleParticipant: Decodable {
    
    var semifinalist: Semifinalist?
    var id: Int?
    var name: String?
    var description: String?
    var profilePhoto: String?
}

struct Battle: Decodable {
    var id: Int
    var endDate: String
    var winnersNumber: Int?
    var totalVotesNumber: Int?
    var battleParticipants: [BattleParticipant]?
    
}

