//
//  RatingProfile.swift
//  AvatarAppIos
//
//  Created by Владислав on 17.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public struct RatingProfile: Codable {
    var likesNumber: Int? = 0
    var video: VideoWebData? = nil
    var id: Int
    var name: String
    var description: String? = nil
    var profilePhoto: String? = nil
}

extension RatingProfile {
    func translatedToUserProfile() -> UserProfile {
        return UserProfile(
            likesNumber: self.likesNumber,
            videos: nil,
            name: self.name,
            id: self.id,
            description: self.description,
            profilePhoto: self.profilePhoto
        )
    }
}
