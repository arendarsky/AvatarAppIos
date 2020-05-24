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

//MARK:- Profile Video View Delegate

extension ProfileViewController: ProfileVideoViewDelegate {
    
    //MARK:- Copy Web Link
    func copyLinkButtonPressed(at index: Int, video: Video) {
        UIPasteboard.general.url = ShareManager.generateWebUrl(from: video.name)
    }
    
    //MARK:- Share Video
    func shareButtonPreseed(at index: Int, video: Video) {
        if let url = ShareManager.generateWebUrl(from: video.name) {
            ShareManager.presentShareMenu(for: url, delegate: self)
        }
    }

    //MARK:- Play Video Button Pressed
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
        
    //MARK:- Video Options Button Pressed
    func optionsButtonPressed(at index: Int, video: Video) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

        //MARK:- Set Video Active
        let setActiveButton = UIAlertAction(title: "Отправить в кастинг", style: .default) { (action) in
            if !(video.isApproved ?? false) {
                self.showIncorrectUserInputAlert(title: "Видео пока нельзя отправить в кастинг",
                                                 message: "Оно ещё не прошло модерацию.")
            } else {
                //MARK:- Set Active Request
                self.loadingIndicatorFullScreen.enableCentered(in: self.view)
                WebVideo.setActive(videoName: video.name) { (isSuccess) in
                    self.loadingIndicatorFullScreen.stopAnimating()
                    if !isSuccess {
                        self.showErrorConnectingToServerAlert(title: "Не удалось связаться с сервером",
                                                              message: "Проверьте подключение к интернету и попробуйте еще раз.")
                    } else {
                        print("Setting Active video named: '\(video.name)'")
                        for videoView in self.videoViews {
                            videoView.notificationLabel.isHidden = (videoView.video.isApproved ?? false)
                        }
                        self.videoViews[index].notificationLabel.isHidden = false
                    }
                }
                //MARK:- Set Active Log
                Amplitude.instance()?.logEvent("sendtocasting_button_tapped")
            }
        }
        
        //MARK:- Edit Video Interval
        let editIntervalButton = UIAlertAction(title: "Изменить фрагмент", style: .default) { (action) in
            self.askUserIfWantsToCancelEditing {
                self.loadingIndicatorFullScreen.enableCentered(in: self.view)
                self.newVideo = video
                self.isEditingVideoInterval = true
                self.performSegue(withIdentifier: "Upload/Edit Video from Profile", sender: nil)
            }
        }

        //MARK:- Delete Video from Profile
        let deleteButton = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
            self.confirmActionAlert(title: "Удалить видео?", message: "Вместе с этим видео из профиля также удалятся все лайки, полученные за него.") { (action) in
                self.deleteVideoRequest(videoName: video.name) {
                    self.rearrangeViewsAfterDelete(video, at: index)
                    self.updateData(isPublic: self.isPublic)
                }
            }
        }
        

        //MARK:- Present Video Options Alert
        alert.addAction(setActiveButton)
        alert.addAction(editIntervalButton)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
}
