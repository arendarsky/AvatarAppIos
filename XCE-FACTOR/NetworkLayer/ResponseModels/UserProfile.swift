//
//  UserProfile.swift
//  AvatarAppIos
//
//  Created by Владислав on 10.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

public struct UserProfile: Codable {
    var likesNumber: Int? = 0
    var videos: [VideoWebData]? = nil
    var name: String = ""
    var id: Int = 0
    var description: String? = nil
    var profilePhoto: String? = nil
    var instagramLogin: String? = nil
}
