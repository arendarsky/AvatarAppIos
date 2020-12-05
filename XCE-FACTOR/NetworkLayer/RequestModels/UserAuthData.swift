//
//  UserAuthData.swift
//  AvatarAppIos
//
//  Created by Владислав on 03.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

struct UserAuthModel: Codable {
    let name: String
    let email: String
    let password: String
    let isConsentReceived: Bool
}
