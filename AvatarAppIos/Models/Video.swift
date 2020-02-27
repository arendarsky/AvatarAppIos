//
//  Video.swift
//  AvatarAppIos
//
//  Created by Владислав on 23.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

class Video {
    var url: URL?
    //in seconds:
    var length: Double = -1
    var startTime: Double = -1
    var endTime: Double = -1
    
    init(stringUrl: String = "", length: Double = -1, startTime: Double = -1, endTime: Double = -1) {
        self.url = URL(string: stringUrl)
        self.length = length
        self.startTime = startTime
        self.endTime = endTime
    }
}
