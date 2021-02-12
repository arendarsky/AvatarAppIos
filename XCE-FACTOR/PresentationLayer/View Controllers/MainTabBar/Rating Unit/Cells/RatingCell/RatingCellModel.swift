//
//  RatingCellModel.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 11.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit.UIImage

struct RatingCellModel {
    var name: String
    var position: String
    var likes: String?
    var description: String?
//    var index: Int
    var isMuteButtonHidden: Bool
    var profileImage: UIImage
    var video: VideoWebData?
}
