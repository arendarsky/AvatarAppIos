//
//MARK:  RatingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import NVActivityIndicatorView

class RatingViewController: XceFactorViewController {

    //MARK:- Properties
    var firstLoad = true
    var index = 0
    private var starsTop = [RatingProfile]()
    private var cachedProfileImages: [UIImage?] = Array(repeating: nil, count: 20)
    private var cachedVideoUrls: [URL?] = Array(repeating: nil, count: 20)
    private var isVideoViewConfigured = Array(repeating: false, count: 20)
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(), type: .circleStrokeSpin, color: .purple, padding: 8.0)
    
    @IBOutlet weak var sessionNotificationLabel: UILabel!
    @IBOutlet weak var ratingCollectionView: UICollectionView!
    
    //MARK:- Rating VC Lifecycle
    ///
    ///
    
    //MARK:- • View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        
        configureCustomNavBar()
        ratingCollectionView.delegate = self
        ratingCollectionView.dataSource = self
        loadingIndicator.enableCentered(in: view)
        updateRatingItems()
        //ratingCollectionView.isPagingEnabled = true
    }
    
    //MARK:- • View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRefrechControl()
        ///update rating every time user switches the tabs
        if !firstLoad {
            for cell in ratingCollectionView.visibleCells {
                (cell as! RatingCell).pauseVideo()
            }
        }
        firstLoad = false
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    //MARK:- • Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).playerVC.player?.pause()
        }
        ratingCollectionView.refreshControl?.removeTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        ratingCollectionView.refreshControl = nil
    }
    
    //MARK:- • Did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).removeVideoObserver()
        }
    }
    
    
    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile from Rating" {
            let vc = segue.destination as! ProfileViewController
            vc.isPublic = true
            vc.userData = starsTop[index].translatedToUserProfile()
            if let img = cachedProfileImages[index] { vc.cachedProfileImage = img }
        }
    }
    
    //MARK:- Configure Refresh Control
    private func configureRefrechControl() {
        ratingCollectionView.refreshControl = nil
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        ratingCollectionView.refreshControl = refreshControl
        
    }
    
    //MARK:- Handle Refresh Control
    @objc private func handleRefreshControl() {
        //Refreshing Data
        updateRatingItems()

        /// Refresh control is being dismissed at the end of updating the rating items
        //DispatchQueue.main.async {
       //     self.ratingCollectionView.refreshControl?.endRefreshing()
        //}
    }

    //MARK:- Update rating items
    private func updateRatingItems() {
        Rating.getRatingData { (serverResult) in
            let header = self.ratingCollectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? CollectionHeaderView
            header?.isHidden = false
            
            //MARK:- Dismiss Refresh Control
            self.ratingCollectionView.refreshControl?.endRefreshing()
            self.loadingIndicator.stopAnimating()

            
            switch serverResult {
                //MARK:- Error Handling
            case .error(let error):
                print("Error: \(error)")
                if self.starsTop.count == 0 {
                    self.sessionNotificationLabel.showNotification(.serverError)
                    header?.isHidden = true
                }
            case .results(let users):
                print("Received \(users.count) users")
                var newTop = [RatingProfile]()
                var newVideoUrls = [URL?]()
                
                for userInfo in users {
                    if let _ = userInfo.video, newTop.count < 20 {
                        newTop.append(userInfo)
                        newVideoUrls.append(userInfo.video?.translatedToVideoType().url)
                    }
                }
                //MARK:- Update Users and Videos List
                print("Users with at least one video: \(newTop.count)")
                if newTop.count > 0 {
                    self.starsTop = newTop
                    self.cachedVideoUrls = newVideoUrls
                    self.cachedProfileImages = Array(repeating: nil, count: 20)
                    self.loadAllProfileImages(for: newTop)
                    self.sessionNotificationLabel.isHidden = true
                    header?.isHidden = false
                    self.ratingCollectionView.reloadData()
                } else {
                    header?.isHidden = true
                    self.sessionNotificationLabel.showNotification(.zeroPeopleInRating)
                }
            }
        }
    }
}

//MARK:- Collection View Data Source & Delegate
extension RatingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starsTop.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //MARK:- Cell Configuration
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pRating Cell", for: indexPath) as! RatingCell
        let item = starsTop[indexPath.row]

        //configure video views inside cells
        //print("count:", starsTop.count)
        print("index", indexPath.row)
        if !ratingCollectionView.refreshControl!.isRefreshing {
            cell.delegate = self
            cell.index = indexPath.row
            cell.configureVideoView(self)
            cell.profileImageView.image = IconsManager.getIcon(.personCircleFill)
            if let image = cachedProfileImages[indexPath.row] {
                cell.profileImageView.image = image
            } else { loadProfileImage(for: item, index: indexPath.row) }
            
            cell.nameLabel.text = item.name
            cell.positionLabel.text = "#" + String(indexPath.row + 1)
            cell.likesLabel.text = item.likesNumber.formattedToLikes()
            cell.descriptionLabel.text = item.description
            
            cell.updatePlayPauseButtonImage()
            cell.playPauseButton.isHidden = false
            //cell.replayButton.isHidden = true
            cell.muteButton.isHidden = !Globals.isMuted
            cell.updateControls()

            //MARK:- Configuring Video
            cacheVideo(for: item, index: indexPath.row)
            cell.configureVideoPlayer(user: item, cachedUrl: cachedVideoUrls[indexPath.row])
        }
        return cell
    }
    
    //MARK:- Did End Displaying Cell
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! RatingCell).pauseVideo()
        for visibleCell in ratingCollectionView.visibleCells {
            (visibleCell as! RatingCell).updateControls()
        }
    }
    
    //MARK: Collection View Header & Footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       switch kind {
       case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "pRating Header", for: indexPath) as? CollectionHeaderView else {
                fatalError("Invalid view type")
            }
            return headerView
       case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "pRating Footer", for: indexPath)
            return footerView
       default:
            assert(false, "Invalid element type")
            return UICollectionReusableView()
        }
    }
    
    //MARK:- Did Select Item at Index Path
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "Profile from Rating", sender: nil)
    }
}

//MARK:- Rating Cell Delegate
///
extension RatingViewController: RatingCellDelegate {
    
    //MARK:- Did Press Play/Pause
    func ratingCellDidPressPlayButton(_ sender: RatingCell) {
        for cell in ratingCollectionView.visibleCells {
            let visibleCell = cell as! RatingCell
            if visibleCell != sender {
                visibleCell.pauseVideo()
            }
        }
    }
    
    //MARK:- Did Press Mute Button
    func ratingCellDidPressMuteButton(_ sender: RatingCell) {
        for cell in ratingCollectionView.visibleCells {
            let visibleCell = cell as! RatingCell
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
        index = sender.index
        performSegue(withIdentifier: "Profile from Rating", sender: nil)
    }
}


extension RatingViewController {
    //MARK:- Cache Video
    func cacheVideo(for user: RatingProfile, index: Int) {
        let video = user.video!.translatedToVideoType()
        CacheManager.shared.getFileWith(fileUrl: video.url) { (result) in
            switch result{
            case.success(let url):
                //print("caching for cell at row '\(index)' complete")
                //caching videos saves their names:
                //print("video name is equal:", url.lastPathComponent == video.url?.lastPathComponent)
                self.cachedVideoUrls[index] = url
            case.failure(let sessionError):
                print(sessionError)
            }
        }
    }
    
    //MARK:- Load Profile Photo
    func loadProfileImage(for user: RatingProfile, index: Int) {
        guard let imageName = user.profilePhoto else {
            print("no profile photo")
            return
        }
        Profile.getProfileImage(name: imageName) { (result) in
            switch result {
            case.error(let error):
                print(error)
            case.results(let image):
                self.cachedProfileImages[index] = image
                if let cell = self.ratingCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? RatingCell {
                    cell.profileImageView.image = image
                }
            }
        }
    }
    
    //MARK:- Load All Profile Images
    func loadAllProfileImages(for users: [RatingProfile]) {
        for (i, user) in users.enumerated() {
            loadProfileImage(for: user, index: i)
        }
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

/*//MARK:- Scroll View Delegate
extension RatingViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in ratingCollectionView.visibleCells {
            //(cell as! RatingCell).pauseVideo()
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        for cell in ratingCollectionView.visibleCells {
            //(cell as! RatingCell).pauseVideo()
        }
    }
/*
 ///for auto playing videos in collection view (not using now)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            /*let cell = ratingCollectionView.visibleCells.last as! RatingCell
            cell.playerVC.player?.play()*/
            for cell in ratingCollectionView.visibleCells {
                (cell as! RatingCell).playPauseButton.isHidden = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /*let cell = ratingCollectionView.visibleCells.last as! RatingCell
        cell.playerVC.player?.play()*/
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).playPauseButton.isHidden = false
        }
    }*/
}*/
