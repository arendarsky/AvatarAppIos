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

    //MARK:- Properties
    let testURL = URL(string: "https://avatarapp.yambr.ru/api/video/call1ezo.ouj.mov")!
    let testURLs = [
        URL(string: "https://vod-progressive.akamaized.net/exp=1583851382~acl=%2A%2F1684003583.mp4%2A~hmac=a21cdd4b10b5b0bfeea6c230bb2d16a6c168348c8dfc39c464b096a7f4c14b93/vimeo-prod-skyfire-std-us/01/4207/15/396036988/1684003583.mp4"),
        URL(string: "https://v.pinimg.com/videos/720p/77/4f/21/774f219598dde62c33389469f5c1b5d1.mp4")
    ]
    var firstLoad = true
    
    private var starsTop = [UserProfile]()
    private var isVideoViewConfigured = Array(repeating: false, count: 20)
    //private var playerVC = AVPlayerViewController()
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var loadingIndicator: NVActivityIndicatorView?
    
    @IBOutlet weak var ratingCollectionView: UICollectionView!
    
    //MARK:- Rating VC Lifecycle
    ///
    ///
    
    //MARK:- • View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingCollectionView.delegate = self
        self.ratingCollectionView.dataSource = self
        
        updateRatingItems()
        
    }
    
    //MARK:- • View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRefrechControl()
        
        ///update rating every time user switches the tabs
        if !firstLoad {
            //updateRatingItems()
        }
        firstLoad = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
    }
    
    //MARK:- • View Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).playerVC.player?.pause()
        }
        ratingCollectionView.refreshControl?.removeTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        ratingCollectionView.refreshControl = nil
    }
    
    //MARK:- Configure Refresh Control
    private func configureRefrechControl() {
        ratingCollectionView.refreshControl = nil
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        ratingCollectionView.refreshControl = refreshControl
        
    }
    
    //MARK:- Handle Refresh Control
    @objc private func handleRefreshControl() {
        //Refreshing Data
        updateRatingItems()

        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.ratingCollectionView.refreshControl?.endRefreshing()
        }
    }

    //MARK:- Update rating items
    private func updateRatingItems() {
        Rating.getData { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert()
            case .results(let users):
                print("Received \(users.count) users")
                var newTop = [UserProfile]()
                for userInfo in users {
                    if userInfo.user.videos.count > 0 {
                        newTop.append(userInfo)
                    }
                }
                print("Users with at least one video: \(newTop.count)")
                if newTop.count > 0 {
                    self.starsTop = newTop
                    self.ratingCollectionView.reloadData()
                }
            }
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

        //configure video views inside cells
        print("count:", starsTop.count)
        print("index", indexPath.row)
        if !ratingCollectionView.refreshControl!.isRefreshing {
        let item = starsTop[indexPath.row]
        //if !isVideoViewConfigured[indexPath.row] {
            configureCellVideoView(cell)
        
            cell.nameLabel.text = item.user.name
            cell.profileImageView.image = UIImage(named: "profileimg32.jpg")
            cell.positionLabel.text = String(indexPath.row + 1) + " место"
            cell.likesLabel.text = "💜 \(item.likesNumber!)"
            cell.descriptionLabel.text = item.user.description
          //  isVideoViewConfigured[indexPath.row] = true
        //}
        
        configureVideoPlayer(in: cell, user: item.user)
        cell.updatePlayPauseButtonImage()
        cell.playPauseButton.isHidden = false
        }
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
        
        cell.playerVC.entersFullScreenWhenPlaybackBegins = false
        cell.playerVC.showsPlaybackControls = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
    }
    
    //MARK:- Configure Video Player
    private func configureVideoPlayer(in cell: RatingCell, user: User) {
        cell.removeVideoObserver()

        //MARK: present video from specified point:
        print("All videos of user '\(user.name)'")
        print(user.videos)
        let video = findUsersActiveVideo(user)
        cell.video = video
        if cell.video.url != nil {
            print(cell.video.url!)
            cell.playerVC.player = AVPlayer(url: cell.video.url!)
        } else {
            print("invalid url. cannot play video")
            return
        }
        
        cell.addVideoObserver()
        cell.playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 600))
        //cell.enableLoadingIndicator()
        
        //cell.playerVC.player?.play()
        
        //print(receivedVideo.length)
    }
 
    //MARK:- Find Active Video
    /** returns the first active video of user's video list
     ❗️works only for Users with non-empty video lists❗️
     */
    private func findUsersActiveVideo(_ user: User) -> Video {
        let res = Video()
        for video in user.videos {
            if video.isActive {
                res.name = video.name
                res.startTime = video.startTime / 1000
                res.endTime = video.endTime / 1000
                res.url = URL(string: "\(domain)/api/video/" + video.name)
                print("start:", res.startTime, "end:", res.endTime)
                break
            }
        }
        return res
    }
    
}


//MARK:- Tab Bar Delegate
extension RatingViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 2 {
            self.ratingCollectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}

//MARK:- Scroll View Delegate
///for auto playing videos in collection view (not using now)

/*
extension RatingViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).playerVC.player?.pause()
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).playerVC.player?.pause()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let cell = ratingCollectionView.visibleCells.last as! RatingCell
            cell.playerVC.player?.play()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cell = ratingCollectionView.visibleCells.last as! RatingCell
        cell.playerVC.player?.play()
    }
}
*/
