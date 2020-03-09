//
//  VideoWebData.swift
//  AvatarAppIos
//
//  Created by Владислав on 06.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct VideoWebData: Codable {
    var name: String = ""
    var isActive: Bool = false
    var startTime: Double = 0.0
    var endTime: Double = 30.0
}
