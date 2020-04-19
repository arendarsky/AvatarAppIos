//
//MARK:  IconsManager.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class IconsManager {
    
    //MARK:- Icon Type
    enum IconType {
        case personCircleFill
        case play
        case pause
        //case plusCircleFill
        case rectangleExpandVertical
        case rectangleCompressVertical
        case mute
        case sound
        case checkmarkSeal
        case optionDots
    }
    
    static func getIcon(_ icon: IconType) -> UIImage? {
        //MARK:- Icons for iOS 13+
       if #available(iOS 13.0, *) {
            switch icon {
            case          .personCircleFill:    return UIImage(systemName: "person.crop.circle.fill")
            case                      .play:    return UIImage(systemName: "play.fill")
            case                     .pause:    return UIImage(systemName: "pause.fill")
            case   .rectangleExpandVertical:    return UIImage(systemName: "rectangle.expand.vertical")
            case .rectangleCompressVertical:    return UIImage(systemName: "rectangle.compress.vertical")
            case                      .mute:    return UIImage(systemName: "speaker.slash.fill")
            case                     .sound:    return UIImage(systemName: "speaker.2.fill")
            case             .checkmarkSeal:    return UIImage(systemName: "checkmark.seal.fill")
            case                .optionDots:    return UIImage(systemName: "ellipsis.circle.fill")
            }
        
        //MARK:- Icons for iOS 12
        } else {
            switch icon {
            case          .personCircleFill:    return UIImage(named: "person.png")
            case                      .play:    return UIImage(named: "playCustom")
            case                     .pause:    return UIImage(named: "pauseCustom")
            case   .rectangleExpandVertical:    return UIImage(named: "expandSquare")
            case .rectangleCompressVertical:    return UIImage(named: "compressSquare")
            case                      .mute:    return UIImage(named: "mute")
            case                     .sound:    return UIImage(named: "sound")
            case             .checkmarkSeal:    return UIImage(named: "checkmark")
            case                .optionDots:    return UIImage(named: "options")
            }
        }
    }
}
