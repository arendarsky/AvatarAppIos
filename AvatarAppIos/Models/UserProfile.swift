//
//  UserProfile.swift
//  AvatarAppIos
//
//  Created by Владислав on 10.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct UserProfile: Codable {
    var likesNumber: Int = 0
    var user: User = User()
}
