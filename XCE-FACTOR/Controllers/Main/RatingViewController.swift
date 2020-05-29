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
import Amplitude

class RatingViewController: XceFactorViewController {

    //MARK:- Properties
    var firstLoad = true
    var index = 0
    let topNumber = 50
    
    private var visibleIndexPath = IndexPath(item: 0, section: 0)
    private var starsTop = [RatingProfile]()
    private var cachedProfileImages = [UIImage?]()
    private var cachedVideoUrls = [URL?]()
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(), type: .circleStrokeSpin, color: .systemPurple, padding: 8.0)
    
    @IBOutlet weak var sessionNotificationLabel: UILabel!
    @IBOutlet weak var ratingCollectionView: UICollectionView!
    
    //MARK:- Rating VC Lifecycle
    ///
    ///
    
    //MARK:- • View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavBar()
        
        configureViews()
        configureRefrechControl()
        updateRatingItems()
    }
    
    //MARK:- • View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            firstLoad = false
        } else {
//            for cell in ratingCollectionView.visibleCells {
//                (cell as! RatingCell).pauseVideo()
//            }
        }
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        autoPlay(at: visibleIndexPath, delay: 0)
    }
    
    //MARK:- • Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        for cell in ratingCollectionView.visibleCells {
//            (cell as! RatingCell).playerVC.player?.pause()
//        }
    }
    
    //MARK:- • Did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pauseAllVideos()
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
    
    //MARK:- INFO PRESSED
    @IBAction func infoButtonPressed(_ sender: Any) {
        presentInfoViewController(
            withHeader: navigationItem.title,
            infoAbout: .rating)
    }
    
    //MARK:- Configure Refresh Control
    private func configureRefrechControl() {
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
                    if let _ = userInfo.video, newTop.count < self.topNumber {
                        newTop.append(userInfo)
                        newVideoUrls.append(userInfo.video?.translatedToVideoType().url)
                    }
                }
                //MARK:- Update Users and Videos List
                print("Users with at least one video: \(newTop.count)")
                if newTop.count > 0 {
                    self.starsTop = newTop
                    self.cachedVideoUrls = newVideoUrls
                    self.cachedProfileImages = Array(repeating: nil, count: self.topNumber)
                    self.loadAllProfileImages(for: newTop)
                    self.sessionNotificationLabel.isHidden = true
                    header?.isHidden = false
                    self.ratingCollectionView.reloadData()
                    self.autoPlay(at: IndexPath(item: 0, section: 0), delay: 0.5)
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
        //performSegue(withIdentifier: "Profile from Rating", sender: nil)
    }
}

//MARK:- Rating Cell Delegate
///
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


extension RatingViewController {
    //MARK:- Configure Views
    private func configureViews() {
        cachedProfileImages = Array(repeating: nil, count: topNumber)
        cachedVideoUrls = Array(repeating: nil, count: topNumber)
        
        ratingCollectionView.delegate = self
        ratingCollectionView.dataSource = self
        loadingIndicator.enableCentered(in: view)
    }
    
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
    
    //MARK:- Pause All Videos
    ///Pauses videos in all visible cells.
    func pauseAllVideos() {
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).pauseVideo()
        }
    }
    
    //MARK:- Auto Playing
    func autoPlayVideos() {
        var visibleRect = CGRect()

        visibleRect.origin = ratingCollectionView.contentOffset
        visibleRect.size = ratingCollectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        guard let indexPath = ratingCollectionView.indexPathForItem(at: visiblePoint), indexPath != visibleIndexPath else { return }
        visibleIndexPath = indexPath
        autoPlayAction(at: indexPath)
    }
    
    //MARK:- Auto Play With Delay
    func autoPlay(at indexPath: IndexPath, delay: Double = 0.5) {
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.autoPlayAction(at: indexPath)
            }
        //This is being done to increase efficency
        } else {
            autoPlayAction(at: indexPath)
        }
    }
    
    ///Firstly, stops videos at visible cells, then hides Play button and plays video at given indexPath with 'playVideo' method
    private func autoPlayAction(at indexPath: IndexPath) {
        for cell in self.ratingCollectionView.visibleCells {
            (cell as! RatingCell).pauseVideo()
        }
        if let cell = self.ratingCollectionView.cellForItem(at: indexPath) as? RatingCell {
            cell.playPauseButton.isHidden = true
            cell.playVideo()
        }
    }
    
}


//MARK:- Tab Bar Delegate
extension RatingViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 2 {
            self.ratingCollectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            autoPlay(at: IndexPath(item: 0, section: 0))
            visibleIndexPath = IndexPath(item: 0, section: 0)
        }
    }
}

//MARK:- Scroll View Delegate
extension RatingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        autoPlayVideos()
    }

    /*//MARK:- Did End Dragging
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            autoPlayVideos()
        }
    }
    
    //MARK:- Did End Decelerating
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        autoPlayVideos()
    }
    
    //MARK:- Did Scroll To Top
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).pauseVideo()
        }
        if let cell = self.ratingCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? RatingCell {
            cell.playVideo()
        }
    }*/
}
