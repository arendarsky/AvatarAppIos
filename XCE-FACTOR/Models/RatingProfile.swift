//
//  RatingProfile.swift
//  AvatarAppIos
//
//  Created by Владислав on 17.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct RatingProfile: Decodable {
    var likesNumber: Int? = 0
    var video: VideoWebData? = nil
    var id: Int
    var name: String
    var description: String? = nil
    var profilePhoto: String? = nil
    
//    private enum CodingKeys: String, CodingKey {
//        case likesNumber = "LikesNumber"
//        case video, id, name, description, profilePhoto
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = try container.decode(Int.self, forKey: .id)
//        name = try container.decode(String.self, forKey: .name)
//        description = try? container.decode(String.self, forKey: .description)
//        profilePhoto = try? container.decode(String.self, forKey: .description)
//        likesNumber = try? container.decode(Int.self, forKey: .likesNumber)
//        video = try? container.decode(VideoWebData.self, forKey: .video)
//    }
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
