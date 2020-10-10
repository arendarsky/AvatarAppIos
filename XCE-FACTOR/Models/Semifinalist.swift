//
//  semifianlist.swift
//  XCE-FACTOR
//
//  Created by user on 20.09.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct Semifinalist: Codable, Hashable {
    var id: Int?
    var videoName: String?
    var votesNumber: Int?
    var isLikedByUser: Bool?
}
