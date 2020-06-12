//
//  MenuManager.swift
//  XCE-FACTOR
//
//  Created by Владислав on 10.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class MenuManager {
    
    static func profileVideoMenuConfig(videoView: ProfileVideoView, identifier: NSString) -> UIContextMenuConfiguration {
        let isVideoReadyToShare = videoView.video.isApproved ?? false
        var attributes = UIMenuElement.Attributes()
        if !isVideoReadyToShare {
            attributes.insert(.disabled)
        }
        var instaActionAttrs = attributes
        if CacheManager.shared.getLocalIfExists(at: videoView.video.url) == nil {
            instaActionAttrs.insert(.disabled)
        }
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { (actions) -> UIMenu? in
            
            let copyLink = UIAction(title: "Скопировать ссылку",
                                    image: UIImage(systemName: "doc.on.doc"),
                                    attributes: attributes) { (action1) in
                videoView.delegate?.copyLinkButtonPressed(at: videoView.index, video: videoView.video)
            }
            
            let shareVideo = UIAction(title: "Поделиться видео",
                                      image: UIImage(systemName: "square.and.arrow.up"),
                                      attributes: attributes) { (action2) in
                videoView.delegate?.shareButtonPreseed(at: videoView.index, video: videoView.video)
            }
            
            let shareToInstagram = UIAction(title: "Добавить в Instagram",
                                            image: IconsManager.getIcon(.instagramLogo),
                                            attributes: instaActionAttrs) { (action3) in
                ShareManager.shareToInstagram(videoUrl: videoView.video.url)
            }
            
            return UIMenu(title: "", children: [shareVideo, copyLink, shareToInstagram])
            
        }
    }
}
