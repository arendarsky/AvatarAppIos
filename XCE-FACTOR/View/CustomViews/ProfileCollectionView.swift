//
//  ProfileCollectionView.swift
//  XCE-FACTOR
//
//  Created by Владислав on 06.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ProfileCollectionView: UICollectionView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
    
    //MARK:- Set New Video Active
    func setNewActiveVideo(named videoName: String) {
        for cell in visibleCells {
            if let videoCell = cell as? ProfileVideoCell, let videoView = videoCell.videoView {
                videoView.video.isActive = videoView.video.name == videoName
                videoCell.setNotificationLabel(with: videoView.video)
            }
        }
    }
}
