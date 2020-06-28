//
//MARK:  IconsManager.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class IconsManager {
    
    //MARK:- Get Icon
    static func getIcon(_ iconType: IconTypes) -> UIImage? {
        return iconType.image
    }
    
    //MARK:- Icon Type
    enum IconTypes {
        case personCircleFill, play, playSmall, pause, plusSmall,
        rectangleExpandVertical, rectangleCompressVertical, expandCorners, mute, sound,
        checkmarkSeal, optionDotsCircleFill, optionDotsSmall,
        barHeart, barBell, barStar, barProfile, heartWhiteSmall,
        repeatAction, repeatActionSmall, instagramLogo, instagramLogo24p,
        shareIcon
        
        var image: UIImage? {
            if #available(iOS 13.0, *) {
                switch self {
                case                 .shareIcon:    return UIImage(systemName: "square.and.arrow.up")
                case          .instagramLogo24p:    return UIImage(named: "instagramLogo24p")
                case             .instagramLogo:    return UIImage(named: "instagramLogo")
                case          .personCircleFill:    return UIImage(systemName: "person.crop.circle.fill")
                case                     .pause:    return UIImage(systemName: "pause.fill")
                case   .rectangleExpandVertical:    return UIImage(systemName: "rectangle.expand.vertical")
                case .rectangleCompressVertical:    return UIImage(systemName: "rectangle.compress.vertical")
                case             .expandCorners:    return UIImage(systemName: "arrow.up.left.and.arrow.down.right")
                case                      .mute:    return UIImage(systemName: "speaker.slash.fill")
                case                     .sound:    return UIImage(systemName: "speaker.2.fill")
                case             .checkmarkSeal:    return UIImage(systemName: "checkmark.seal.fill")
                case      .optionDotsCircleFill:    return UIImage(systemName: "ellipsis.circle.fill")
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
                switch self {
                case .shareIcon:    return nil //need to manually download
                case          .instagramLogo24p:    return UIImage(named: "instagramLogo24p")
                case             .instagramLogo:    return UIImage(named: "instagramLogo")
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
                case                .optionDotsCircleFill:    return UIImage(named: "options")
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
}
