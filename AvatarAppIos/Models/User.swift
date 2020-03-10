//
//  User.swift
//  AvatarAppIos
//
//  Created by Владислав on 09.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct User: Codable {
    var name: String = ""
    var description: String? = nil
    var profilePhoto: String? = nil
    var videos: [VideoWebData] = [VideoWebData]()
}
