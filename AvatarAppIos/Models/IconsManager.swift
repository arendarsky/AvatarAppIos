//
//  IconsManager.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class IconsManager {
    
    enum IconType {
        case personCircleFill
        case play
        case pause
        case plusCircleFill
        case rectangleExpandVertical
        case rectangleCompressVertical
        case mute
        case sound
        case checkmarkSeal
        case optionDots
    }
    
    static func getIcon(_ icon: IconType) -> UIImage? {
        switch icon {
        case .personCircleFill:
            return UIImage(systemName: "person.crop.circle.fill")
        case .play:
            return UIImage(systemName: "play.fill")
        case .pause:
            return UIImage(systemName: "pause.fill")
        case .plusCircleFill:
            return UIImage(systemName: "plus.circle.fill")
        case .rectangleExpandVertical:
            return UIImage(systemName: "rectangle.expand.vertical")
        case .rectangleCompressVertical:
            return UIImage(systemName: "rectangle.compress.vertical")
        case .mute:
            return UIImage(systemName: "speaker.slash.fill")
        case .sound:
            return UIImage(systemName: "speaker.2.fill")
        case .checkmarkSeal:
            return UIImage(systemName: "checkmark.seal.fill")
        case .optionDots:
            return UIImage(systemName: "ellipsis.circle.fill")
        }
    }
}
