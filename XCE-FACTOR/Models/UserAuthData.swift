//
//  UserAuthData.swift
//  AvatarAppIos
//
//  Created by Владислав on 03.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct UserAuthData: Codable {
    var name: String?
    var email: String
    var password: String
    var ConsentToGeneralEmail: Bool
}
