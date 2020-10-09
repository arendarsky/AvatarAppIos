//
//  CastingContextMenu.swift
//  XCE-FACTOR
//
//  Created by Владислав on 22.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

//MARK:- CastingView must be rewritten into its own class
// and this is a temporary solution

extension CastingViewController {
    
    //MARK:- Share Menu Pressed
    @IBAction func castingMenuPressed(_ sender: Any) {
        let instBtn = UIAlertAction(title: "Добавить в историю", image: IconsManager.getIcon(.instagramLogo24p), style: .default) { (share) in
            self.prepareAndShareToStories(videoUrl: self.receivedVideo.url, enableActivityHandler: {
                self.setViewsInteraction(enabled: false)
            }, disableActivityHandler: {
                self.setViewsInteraction(enabled: true)
            })            
        }
        let shareIcon = IconsManager.getIcon(.shareIcon)?.applyingSymbolConfiguration(.init(pointSize: 24, weight: .regular))
        let shareBtn = UIAlertAction(title: "Поделиться…", image: shareIcon, style: .default) { (action1) in
            ShareManager.presentShareSheetVC(for: self.receivedVideo, delegate: self)
        }
        
        showActionSheetWithOptions(title: nil, buttons: [instBtn, shareBtn])
        
    }
    
}
