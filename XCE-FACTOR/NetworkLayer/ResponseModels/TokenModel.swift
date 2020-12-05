//
//  TokenModel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 22.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

struct TokenModel: Decodable {
    let token: String?
    let confirmationRequired: Bool
}
