//
//  VideoWebData.swift
//  AvatarAppIos
//
//  Created by Владислав on 06.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct VideoWebData: Codable {
    var name: String
    var isActive: Bool
    var isApproved: Bool? = true
    var startTime: Double
    var endTime: Double
}
