//
//  RatingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import NVActivityIndicatorView

class RatingViewController: UIViewController {

    let testURL = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2019/215wh1hurdxwcctfc8/215/215_hd_advances_in_collection_view_layout.mp4")
    
    private var starsTop = [RatingItem]()
    private var isVideoViewConfigured = false
    //private var playerVC = AVPlayerViewController()
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var loadingIndicator: NVActivityIndicatorView?
    
    @IBOutlet weak var ratingCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingCollectionView.delegate = self
        self.ratingCollectionView.dataSource = self
        
        //MARK:- Fetch rating items
        for i in 1...20 {
            let item: RatingItem = RatingItem(likesNumber: 10*i,
                user: UserProfileInfo(guid: "asds",
                    name: "Человек номер \(i)",
                    description: "крутейшее описание",
                    videos: [VideoWebData(name: "asdasd",
                                          isActive: true,
                                          startTime: 0.0,
                                          endTime: 15.0)]))
            starsTop.append(item)
        }
    }

    
}

//MARK:- Collection View Delegate & Data Source
extension RatingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starsTop.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //MARK:- Cell Configuration
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pRating Cell", for: indexPath) as! RatingCell

        //configure video views inside cells for the 1st time
        if !isVideoViewConfigured {
            configureCellVideoView(cell)
        }
        
        let item = starsTop[indexPath.row]
        cell.nameLabel.text = item.user.name
        cell.profileImageView.image = UIImage(named: "profileimg32.jpg")
        cell.positionLabel.text = String(indexPath.row + 1) + " место"
        cell.likesLabel.text = "❤️ \(item.likesNumber)"
        cell.descriptionLabel.text = item.user.description
        
        //if cell is visible:
        
        configureVideoPlayer(with: testURL, in: cell, user: item.user)
        
        return cell
    }

    //MARK: Collection View Header & Footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       switch kind {
       case UICollectionView.elementKindSectionHeader:
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "pRating Header", for: indexPath) as? CollectionHeaderView
                else {
                     fatalError("Invalid view type")
            }
             //headerView.sectionHeader.text = "ТОП-20"
             //headerView.title.text = "Label"
            return headerView
       case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "pRating Footer", for: indexPath)
            return footerView
       default:
            assert(false, "Invalid element type")
            return UICollectionReusableView()
        }
    }
}

extension RatingViewController {
    //MARK:- Configure Video View
    private func configureCellVideoView(_ cell: RatingCell) {
        cell.playerVC.view.frame = cell.videoView.bounds
        //fill video content in frame ⬇️
        cell.playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cell.playerVC.view.layer.masksToBounds = true
        cell.playerVC.view.layer.cornerRadius = 25
        cell.playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        cell.playerVC.view.backgroundColor = .quaternarySystemFill

        //MARK:- insert player into videoView
        self.addChild(cell.playerVC)
        cell.playerVC.didMove(toParent: self)
        cell.videoView.insertSubview(cell.playerVC.view, belowSubview: cell.positionLabel)
        cell.videoView.backgroundColor = .clear
        
        //cell.playerVC.showsPlaybackControls = false
        cell.playerVC.entersFullScreenWhenPlaybackBegins = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
    }
    
    //MARK:- Configure Video Player
    private func configureVideoPlayer(with url: URL?, in cell: RatingCell, user: UserProfileInfo) {
        //removeVideoObserver()
        
        if url != nil {
            cell.playerVC.player = AVPlayer(url: url!)
        } else {
            print("invalid url. cannot play video")
            return
        }

        //MARK: present video from specified point:
        let video = findUsersActiveVideo(user)
        cell.playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 600))
        //cell.playerVC.player?.play()
        
        //print(receivedVideo.length)
        //addVideoObserver()
    }
 
    //MARK:- Find Active Video
    /// returns the first active video of user's video list
    private func findUsersActiveVideo(_ user: UserProfileInfo) -> Video {
        let res = Video()
        for video in user.videos {
            if video.isActive {
                res.name = video.name
                res.startTime = video.startTime / 1000
                res.endTime = video.endTime / 1000
                print("start:", res.startTime, "end:", res.endTime)
                break
            }
        }
        return res
    }
    
//    //MARK:- Remove All Video Observers
//    private func removeVideoObserver() {
//        if let timeObserver = self.videoTimeObserver {
//            //removing time obse
//            playerVC.player?.removeTimeObserver(timeObserver)
//            videoTimeObserver = nil
//        }
//        if self.videoDidEndPlayingObserver != nil {
//            NotificationCenter.default.removeObserver(self)
//            videoDidEndPlayingObserver = nil
//        }
//    }
//
//    //MARK:- Add All Video Observers
//    private func addVideoObserver() {
//        removeVideoObserver()
//
//        //MARK:- Video Time Observer
//        let interval = CMTimeMake(value: 1, timescale: 100)
//        videoTimeObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
//
//            //MARK:- • stop video at specified time.
//            // (Can also make progressView for showing as a video progress from here later)
//            let currentTime = CMTimeGetSeconds(time)
//            //print(currentTime)
//            if abs(currentTime - self!.receivedVideo.endTime) <= 0.01 {
//                self?.playerVC.player?.pause()
//                self?.replayButton.isHidden = false
//            } else {
//                //self?.disableLoadingIndicator()
//                self?.replayButton.isHidden = true
//            }
//
//            //MARK:- • enable loading indicator when player is loading
//            switch self?.playerVC.player?.currentItem?.status{
//            case .readyToPlay:
//                if (self?.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp)! {
//                    self?.disableLoadingIndicator()
//                } else {
//                    self?.enableLoadingIndicator()
//                }
//
//                if (self?.playerVC.player?.currentItem?.isPlaybackBufferEmpty)! {
//                    self?.enableLoadingIndicator()
//                }else {
//                    self?.disableLoadingIndicator()
//                }
//                break
//            case .failed:
//                self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
//                break
//            default:
//                break
//            }
//        }
//
//        //MARK: Video Did End Playing Observer
//        videoDidEndPlayingObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerVC.player?.currentItem)
//    }
//
//    @objc private func videoDidEnd() {
//        replayButton.isHidden = false
//    }
}
