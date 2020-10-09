//
//  CastingVideo.swift
//  AvatarAppIos
//
//  Created by Владислав on 17.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct CastingVideo: Codable, Hashable {
    var id: Int
    var video: VideoWebData
    var name: String?
    var description: String? = nil
    var profilePhoto: String? = nil
    
    //id determines the author but if the video is new, the object seems to be different
    static func == (lhs: CastingVideo, rhs: CastingVideo) -> Bool {
        return lhs.id == rhs.id && lhs.video == rhs.video
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
