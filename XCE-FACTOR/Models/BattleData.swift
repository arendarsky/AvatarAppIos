//
//  Battle.swift
//  XCE-FACTOR
//
//  Created by Sergey Desenko on 20.09.2020.
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
