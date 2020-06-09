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
    
    //MARK:- Delete Video at Index
    func deleteVideo(at index: Int, completion: (() -> Void)? = nil) {
        //check if there is a button at the first cell (not a video view)
        if let _ = cellForItem(at: IndexPath(item: 0, section: 0)) as? ProfileVideoCell {
            performBatchUpdates({
                deleteItems(at: [IndexPath(item: index, section: 0)])
                insertItems(at: [IndexPath(item: 0, section: 0)])
            }, completion: { (completed) in
                completion?()
            })
        } else {
            deleteItems(at: [IndexPath(item: index + 1, section: 0)])
            completion?()
        }
        
        for cell in visibleCells {
            if let videoView = (cell as? ProfileVideoCell)?.videoView, videoView.index > index {
                videoView.index -= 1
            }
        }
    }
}
