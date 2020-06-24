//
//  RatingCellDelegate.swift
//  XCE-FACTOR
//
//  Created by Владислав on 30.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import Amplitude


//MARK:- Rating Cell Delegate
///
///
extension RatingViewController: RatingCellDelegate {
    
    //MARK:- Did Press Play/Pause
    func ratingCellDidPressPlayButton(_ sender: RatingCell) {
        for cell in ratingCollectionView.visibleCells {
            guard let visibleCell = cell as? RatingCell else { return }
            if visibleCell != sender {
                visibleCell.pauseVideo()
            }
        }
    }
    
    //MARK:- Did Press Mute Button
    func ratingCellDidPressMuteButton(_ sender: RatingCell) {
        for cell in ratingCollectionView.visibleCells {
            guard let visibleCell = cell as? RatingCell else { return }
            if visibleCell != sender {
                visibleCell.updateControls()
                if Globals.isMuted {
                    visibleCell.muteButton.isHidden = false
                }
            }
        }
    }
    
    //MARK:- Did Tap On Profile
    func handleTapOnRatingCell(_ sender: RatingCell) {
        performSegue(withIdentifier: "Profile from Rating", sender: IndexPath(item: sender.index, section: 1))
        
        //MARK:- Profile from Rating Log
        Amplitude.instance()?.logEvent("ratingprofile_button_tapped")
    }
    
    //MARK:- Did Press Share Button
    func ratingcellDidPressMenu(_ sender: RatingCell) {
        guard let video = starsTop[sender.index].video?.translatedToVideoType() else {
            print("Rating Video error when trying to share")
            return
        }
        let shareImg = IconsManager.getIcon(.shareIcon)?.applyingSymbolConfiguration(.init(pointSize: 24, weight: .regular))
        let buttons = [
            UIAlertAction(title: "Добавить в историю", image: IconsManager.getIcon(.instagramLogo24p), style: .default) { (action) in
                self.prepareAndShareToStories(videoUrl: video.url, enableActivityHandler: {
                    self.ratingCollectionView.isUserInteractionEnabled = false
                }, disableActivityHandler: {
                    self.ratingCollectionView.isUserInteractionEnabled = true
                })
            },
            UIAlertAction(title: "Поделиться…", image: shareImg, style: .default, handler: { (action) in
                ShareManager.presentShareSheetVC(for: video, delegate: self)
            })
        ]
//        if CacheManager.shared.getLocalIfExists(at: video.url) == nil {
//            buttons.first?.isEnabled = false
//        }
        showActionSheetWithOptions(title: nil, buttons: buttons)
    }
    
    //MARK:- Failed To Load Video
    func ratingCellFailedToLoadVideo(_ sender: RatingCell) {
        sender.prepareForReload()
        sender.playVideo()
    }

}
