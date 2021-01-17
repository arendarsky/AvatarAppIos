//
//  ProfileVideosDelegate.swift
//  XCE-FACTOR
//
//  Created by Владислав on 24.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import Amplitude
import MobileCoreServices

//MARK:- Profile Video View Delegate

extension ProfileViewController: ProfileVideoViewDelegate, AddVideoCellDelegate {
    
    func addNewVideoButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        askUserIfWantsToCancelEditing {
            self.showMediaPickAlert(mediaTypes: [kUTTypeMovie], delegate: self, allowsEditing: false, title: "Добавьте новое видео")
            
            //MARK:- New Video Button Pressed Log
            Amplitude.instance()?.logEvent("newvideo_squared_button_tapped")
        }
    }
    
    /// Copy Web Link
    func copyLinkButtonPressed(at index: Int, video: Video) {
        UIPasteboard.general.url = ShareManager.generateWebUrl(from: video.name)
    }
    
    /// Share Video
    func shareButtonPreseed(at index: Int, video: Video) {
        ShareManager.presentShareSheetVC(for: video, delegate: self)
    }
    
    /// Share to Stories
    func shareToInstagramStoriesButtonPressed(at index: Int, video: Video) {
        prepareAndShareToStories(videoUrl: video.url, enableActivityHandler: {
            URLSession.shared.invalidateAndCancel()
            self.profileCollectionView.isUserInteractionEnabled = false
        }, disableActivityHandler: {
            self.profileCollectionView.isUserInteractionEnabled = true
        })
    }

    /// Play Video Button Pressed
    func playButtonPressed(at index: Int, video: Video) {
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = AVPlayer(url: video.url!)
        fullScreenPlayerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
        fullScreenPlayerVC.player?.isMuted = Globals.isMuted
        
        handlePossibleSoundError()
        present(fullScreenPlayerVC, animated: true) {
            fullScreenPlayerVC.player?.play()
        }
    }
        
    /// Video Options Button Pressed
    func optionsButtonPressed(at index: Int, video: Video) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

        // Set Video Active
        let setActiveButton = UIAlertAction(title: "Отправить в кастинг", style: .default) { (action) in
            guard let isApproved = video.isApproved else {
                self.alertFactory?.showAlert(type: .notAllowToCasting)
                return
            }
            guard isApproved else {
                self.alertFactory?.showAlert(type: .videoRejectByModerator)
                return
            }
            
            // Set Active Request
            self.loadingIndicatorFullScreen.enableCentered(in: self.view)
            WebVideo.setActive(videoName: video.name) { (isSuccess) in
                self.loadingIndicatorFullScreen.stopAnimating()
                if !isSuccess {
                    self.alertFactory?.showAlert(type: .connectionToServerErrorReconnect)
                }
                else {
                    print("Setting Active video named: '\(video.name)'")
                    self.profileCollectionView.setNewActiveVideo(named: video.name)
                }
            }
            // Set Active Log
            Amplitude.instance()?.logEvent("sendtocasting_button_tapped")
        }
        
        /// Edit Video Interval
        let editIntervalButton = UIAlertAction(title: "Изменить фрагмент", style: .default) { (action) in
            self.askUserIfWantsToCancelEditing {
                self.loadingIndicatorFullScreen.enableCentered(in: self.view)
                self.newVideo = video
                self.isEditingVideoInterval = true
                self.performSegue(withIdentifier: "Upload/Edit Video from Profile", sender: nil)
            }
        }

        /// Delete Video from Profile
        let deleteButton = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
            self.confirmActionAlert(title: "Удалить видео?", message: "Вместе с этим видео из профиля также удалятся все лайки, полученные за него.") { (action) in
                self.deleteVideoRequest(videoName: video.name) {
                    self.videosData.remove(at: index)
                    self.profileCollectionView.deleteVideo(at: index)
                    self.updateData(isPublic: self.isPublic)
                }
            }
        }
        

        /// Present Video Options Alert
        alert.addAction(setActiveButton)
        alert.addAction(editIntervalButton)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
}
