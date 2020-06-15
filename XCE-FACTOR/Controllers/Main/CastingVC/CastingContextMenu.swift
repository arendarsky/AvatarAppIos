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
        let buttons = [
            UIAlertAction(title: "Поделиться в Instagram", style: .default) { (share) in
                if let url = CacheManager.shared.getLocalIfExists(at: self.receivedVideo.url) {
                    ShareManager.shareToInstagram(videoUrl: url)
                } else {
                    self.sharePreparingView.setViewWithAnimation(in: self.view, hidden: false, duration: 0.3)
                    self.setViewsInteraction(enabled: false)
                    self.cacheVideo(with: self.receivedVideo.url) { (url) in
                        self.sharePreparingView.isHidden = true
                        self.setViewsInteraction(enabled: true)
                        
                        self.disableLoadingIndicator()
                        guard let localUrl = url else {
                            //self.showErrorConnectingToServerAlert()
                            return
                        }
                        ShareManager.shareToInstagram(videoUrl: localUrl)
                    }
                }
                
            },
            UIAlertAction(title: "Ещё...", style: .default) { (action1) in
                ShareManager.presentShareSheetVC(for: self.receivedVideo, delegate: self)
            }
        ]
        showActionSheetWithOptions(title: nil, buttons: buttons)
        
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
