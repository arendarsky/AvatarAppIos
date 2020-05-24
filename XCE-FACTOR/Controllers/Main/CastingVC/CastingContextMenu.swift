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
    
    @IBAction func castingMenuPressed(_ sender: Any) {
        if let url = ShareManager.generateWebUrl(from: receivedVideo.name) {
            ShareManager.presentShareMenu(for: url, delegate: self)
        }
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