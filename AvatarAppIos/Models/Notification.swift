//
//  Notification.swift
//  AvatarAppIos
//
//  Created by Владислав on 17.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public struct Notification: Codable {
    var id: Int
    var name: String
    var description: String? = nil
    var profilePhoto: String? = nil
}
