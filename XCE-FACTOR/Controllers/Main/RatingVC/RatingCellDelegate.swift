//
//  RatingCellDelegate.swift
//  XCE-FACTOR
//
//  Created by Владислав on 30.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
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
    
    //MARK:- Did Press Menu
    func ratingcellDidPressMenu(_ sender: RatingCell) {
        if let url = ShareManager.generateWebUrl(from: starsTop[sender.index].video?.name) {
            ShareManager.presentShareMenu(for: url, delegate: self)
        }
    }
    
    //MARK:- Failed To Load Video
    func ratingCellFailedToLoadVideo(_ sender: RatingCell) {
        sender.prepareForReload()
        sender.playVideo()
    }
}

