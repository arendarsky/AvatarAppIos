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
    
    ///in milliseconds
    var startTime: Double
    var endTime: Double
}

extension VideoWebData {
    func translateToVideoType() -> Video {
        let res = Video()
        res.startTime = startTime / 1000
        res.endTime = endTime / 1000
        res.isActive = isActive
        res.name = name
        res.url = URL(string: "\(domain)/api/video/" + name)
        
        return res
    }
}
