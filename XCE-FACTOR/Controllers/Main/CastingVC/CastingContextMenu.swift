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
        let instBtn = UIAlertAction(title: "Поделиться в Instagram", image: IconsManager.getIcon(.instagramLogo24p), style: .default) { (share) in
            if let url = CacheManager.shared.getLocalIfExists(at: self.receivedVideo.url) {
                ShareManager.shareToInstagramStories(videoUrl: url, self)
            } else {
                self.enableActivityView()
                //self.sharePreparingView.setViewWithAnimation(in: self.view, hidden: false, duration: 0.3)
                self.setViewsInteraction(enabled: false)
                self.cacheVideo(with: self.receivedVideo.url) { (url) in
                    self.disableActivityView()
                    //self.sharePreparingView.isHidden = true
                    self.setViewsInteraction(enabled: true)
                    
                    self.disableLoadingIndicator()
                    guard let localUrl = url else {
                        if !(self.cacheRequest?.isCancelled ?? true) {
                            self.showErrorConnectingToServerAlert(title: "Не удалось поделиться", message: "Не удалось связаться с сервером для отправки видео в Instagram. Проверьте подключение к интернету")
                        }
                        //self.showErrorConnectingToServerAlert()
                        return
                    }
                    ShareManager.shareToInstagramStories(videoUrl: localUrl, self)
                }
            }
            
        }
        let shareIcon = IconsManager.getIcon(.shareIcon)?.applyingSymbolConfiguration(.init(pointSize: 24, weight: .regular))
        let shareBtn = UIAlertAction(title: "Ещё...", image: shareIcon, style: .default) { (action1) in
            ShareManager.presentShareSheetVC(for: self.receivedVideo, delegate: self)
        }
        
        showActionSheetWithOptions(title: nil, buttons: [instBtn, shareBtn])
        
    }
    
    //MARK:- Add Context Menu - developing
//    func addContextMenu() {
//        let interaction = UIContextMenuInteraction(delegate: self)
//        castingView.addInteraction(interaction)
//    }
    
}


// developing now
//extension CastingViewController: UIContextMenuInteractionDelegate {
//
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        return nil
//    }
//
//}
