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
    enum IconTypes {
        case personCircleFill
        case play
        case playSmall
        case pause
        case plusSmall
        case rectangleExpandVertical
        case rectangleCompressVertical
        case expandCorners
        case mute
        case sound
        case checkmarkSeal
        case optionDots
        case optionDotsSmall
        case barHeart
        case barBell
        case barStar
        case barProfile
        case heartWhiteSmall
        case repeatAction
        case repeatActionSmall
    }
    
    static func getIcon(_ iconType: IconTypes) -> UIImage? {
        //MARK:- Icons for iOS 13+
       if #available(iOS 13.0, *) {
            switch iconType {
            case          .personCircleFill:    return UIImage(systemName: "person.crop.circle.fill")
            case                     .pause:    return UIImage(systemName: "pause.fill")
            case   .rectangleExpandVertical:    return UIImage(systemName: "rectangle.expand.vertical")
            case .rectangleCompressVertical:    return UIImage(systemName: "rectangle.compress.vertical")
            case             .expandCorners:    return UIImage(systemName: "arrow.up.left.and.arrow.down.right")
            case                      .mute:    return UIImage(systemName: "speaker.slash.fill")
            case                     .sound:    return UIImage(systemName: "speaker.2.fill")
            case             .checkmarkSeal:    return UIImage(systemName: "checkmark.seal.fill")
            case                .optionDots:    return UIImage(systemName: "ellipsis.circle.fill")
            case           .optionDotsSmall:    return UIImage(systemName: "ellipsis")
            case                   .barBell:    return UIImage(systemName: "bell.fill")
            case                   .barStar:    return UIImage(systemName: "star.fill")
            case                .barProfile:    return UIImage(systemName: "person.fill")
            case                 .plusSmall:    return UIImage(systemName: "plus")
            case                 .play,
                                 .playSmall:    return UIImage(systemName: "play.fill")
            case           .barHeart,
                           .heartWhiteSmall:    return UIImage(systemName: "heart.fill")
            case         .repeatAction,
                         .repeatActionSmall:    return UIImage(systemName: "arrow.counterclockwise")
        }
        
        //MARK:- Icons for iOS 12
        } else {
            switch iconType {
            case          .personCircleFill:    return UIImage(named: "person.png")
            case                      .play:    return UIImage(named: "playCustom")
            case                 .playSmall:    return UIImage(named: "playSmall")
            case                     .pause:    return UIImage(named: "pauseCustom")
            case   .rectangleExpandVertical:    return UIImage(named: "expandSquare")
            case .rectangleCompressVertical:    return UIImage(named: "compressSquare")
            case             .expandCorners:    return UIImage(named: "expandCorners")
            case                      .mute:    return UIImage(named: "mute")
            case                     .sound:    return UIImage(named: "sound")
            case             .checkmarkSeal:    return UIImage(named: "checkmark")
            case                .optionDots:    return UIImage(named: "options")
            case           .optionDotsSmall:    return UIImage(named: "optionsSmall")
            case                   .barBell:    return UIImage(named: "barBell")
            case                   .barStar:    return UIImage(named: "barStar")
            case                .barProfile:    return UIImage(named: "barProfile")
            case                 .plusSmall:    return UIImage(named: "plusSmall")
            case                  .barHeart:    return UIImage(named: "barHeart")
            case           .heartWhiteSmall:    return UIImage(named: "heartWhiteSmall")
            case              .repeatAction:    return UIImage(named: "repeatAction")
            case         .repeatActionSmall:    return UIImage(named: "repeatActionSmall")
            }
        }
    }
}
