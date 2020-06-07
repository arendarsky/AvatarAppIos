//
//  ProfileVideoCell.swift
//  XCE-FACTOR
//
//  Created by Владислав on 05.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit

class ProfileVideoCell: UICollectionViewCell {
    
    @IBOutlet weak var videoView: ProfileVideoView!
    
    override func awakeFromNib() {
        configureViews()
    }
    
    func configureViews(){
        contentView.layer.cornerRadius = 10
        videoView.layer.cornerRadius = 10
    }
    
    //MARK:- Configure Cell
    func configureCell(at index: Int, with video: Video, delegate: ProfileVideoViewDelegate) {
        videoView.delegate = delegate
        videoView.index = index
        
        if videoView.video.name != video.name || videoView.thumbnailImageView.image == nil {
            videoView.thumbnailImageView.image = nil
            videoView.loadingIndicator.startAnimating()
        }
        videoView.video = video
        //MARK:- Cache Video
        cacheVideoAndGetPreviewImage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadVideoPreviewImage()
        }
        
        setNotificationLabel(with: video)
    }
    
    //MARK: Set Notification Label
    func setNotificationLabel(with video: Video) {
        videoView.notificationLabel.isHidden = false
        if video.isActive {
            videoView.notificationLabel.text = "В Кастинге"
            return
        }
        guard let isApproved = video.isApproved else {
            videoView.notificationLabel.text = "На модерации"
            return
        }
        if isApproved {
            videoView.notificationLabel.isHidden = true
        } else {
            videoView.notificationLabel.text = "Не прошло проверку"
        }
    }
}

extension ProfileVideoCell {
    
    //MARK:- Cache Video and Get Preview Image
    private func cacheVideoAndGetPreviewImage() {
        CacheManager.shared.getFileWith(fileUrl: videoView.video.url, specifiedTimeout: 10) { (result) in
            //self.videoViews[index].loadingIndicator.stopAnimating()
            
            switch result {
            case.failure(let sessionError):
                print("Error Caching Profile Video: \(sessionError)")
                self.loadVideoPreviewImage()
                
            case.success(let cachedUrl):
                self.videoView.video.url = cachedUrl
                self.loadVideoPreviewImage()
            }
        }
    }
    
    //MARK:- Load Video Preview Image
    func loadVideoPreviewImage() {
        //if self.videoViews[index].thumbnailImageView.image == nil {
        VideoHelper.createVideoThumbnail(
            from: videoView.video.url,
            timestamp: CMTime(seconds: videoView.video.startTime, preferredTimescale: 1000)) { (image) in
                
                self.videoView.loadingIndicator.stopAnimating()
                if image != nil {
                    self.videoView.thumbnailImageView.image = image
                }
        }
        //}
    }
    
}
