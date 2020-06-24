//
//MARK:  MenuManager.swift
//  XCE-FACTOR
//
//  Created by Владислав on 10.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class MenuManager {
    
    //MARK:- Profile Video Menu
    static func profileVideoMenuConfig(videoView: ProfileVideoView, identifier: NSString) -> UIContextMenuConfiguration {
        let isVideoReadyToShare = videoView.video.isApproved ?? false
        var attributes = UIMenuElement.Attributes()
        if !isVideoReadyToShare {
            attributes.insert(.disabled)
        }
        let instaActionAttrs = attributes
//        if CacheManager.shared.getLocalIfExists(at: videoView.video.url) == nil {
//            instaActionAttrs.insert(.disabled)
//        }
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { (actions) -> UIMenu? in
            
            let copyLink = UIAction(
                title: "Скопировать ссылку",
                image: UIImage(systemName: "doc.on.doc"),
                attributes: attributes) { (action1) in
                    videoView.delegate?.copyLinkButtonPressed(at: videoView.index, video: videoView.video)
            }
            
            let shareVideo = UIAction(
                title: "Поделиться…",
                image: IconsManager.getIcon(.shareIcon),
                attributes: attributes) { (action2) in
                    videoView.delegate?.shareButtonPreseed(at: videoView.index, video: videoView.video)
            }
            
            let shareToInstagram = UIAction(
                title: "Добавить в историю",
                image: IconsManager.getIcon(.instagramLogo),
                attributes: instaActionAttrs) { (action3) in
                    videoView.delegate?.shareToInstagramStoriesButtonPressed(at: videoView.index, video: videoView.video)
                //ShareManager.shareToInstagramStories(videoUrl: videoView.video.url, nil)
            }
            
            return UIMenu(title: "", children: [shareVideo, copyLink, shareToInstagram])
            
        }
    }
    
    
    //MARK:- Instagram Profile Button Menu
    static func instagramProfileMenuConfig(_ delegate: ProfileUserInfoViewDelegate, isPublic: Bool, userData: UserProfile) -> UIContextMenuConfiguration? {
        guard let username = userData.instagramLogin else {
            return nil
        }
        var editActionAttrs = UIMenuElement.Attributes()
        var copyActionAttrs = editActionAttrs
        var editTitle = "Редактировать"
        if isPublic {
            editActionAttrs.insert(.disabled)
            editActionAttrs.insert(.hidden)
        } else if username == "" {
            copyActionAttrs.insert(.disabled)
            copyActionAttrs.insert(.hidden)
            editTitle = "Добавить"
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
            let editAction = UIAction(
                title: editTitle,
                image: UIImage(systemName: "square.and.pencil"),
                attributes: editActionAttrs) { (editAct) in
                    delegate.didPressEditInstagramButton()
            }
            
            let copyUsername = UIAction(
                title: "Скопировать",
                image: UIImage(systemName: "doc.on.doc"),
                attributes: copyActionAttrs) { (copy) in
                    delegate.didPressCopyButton()
            }
            
            // + open in safari
            let menuTitle = username == "" ? "Аккаунт не добавлен" : "@\(username)"
            return UIMenu(title: menuTitle, children: [editAction, copyUsername])
        }
    }
}
