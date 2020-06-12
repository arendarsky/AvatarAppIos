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
    
    //MARK:- Copy Web Link
    func copyLinkButtonPressed(at index: Int, video: Video) {
        UIPasteboard.general.url = ShareManager.generateWebUrl(from: video.name)
    }
    
    //MARK:- Share Video
    func shareButtonPreseed(at index: Int, video: Video) {
        ShareManager.presentShareMenu(for: video, delegate: self)
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
            guard let isApproved = video.isApproved else {
                self.showIncorrectUserInputAlert(title: "Видео пока нельзя отправить в Кастинг",
                                                message: "Оно ещё не прошло модерацию.")
                return
            }
            guard isApproved else {
                self.showIncorrectUserInputAlert(title: "Видео не прошло модерацию, его нельзя отправлять в Кастинг",
                                                message: "Вы можете удалить это видео и загрузить новое")
                return
            }
            
            //MARK:- Set Active Request
            self.loadingIndicatorFullScreen.enableCentered(in: self.view)
            WebVideo.setActive(videoName: video.name) { (isSuccess) in
                self.loadingIndicatorFullScreen.stopAnimating()
                if !isSuccess {
                    self.showErrorConnectingToServerAlert(
                        title: "Не удалось связаться с сервером",
                        message: "Проверьте подключение к интернету и попробуйте еще раз.")
                }
                else {
                    print("Setting Active video named: '\(video.name)'")
                    self.profileCollectionView.setNewActiveVideo(named: video.name)
                }
            }
            //MARK:- Set Active Log
            Amplitude.instance()?.logEvent("sendtocasting_button_tapped")
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
                    self.videosData.remove(at: index)
                    self.profileCollectionView.deleteVideo(at: index)
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
