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
    let topNumber = 50
    var firstLoad = true

    var semifinalists = [RatingProfile]()
    var cachedSemifinalistsImages = [UIImage?]()
    var starsTop = [RatingProfile]()
    var cachedProfileImages = [UIImage?]()
    var cachedVideoUrls = [URL?]()
    private var visibleIndexPath = IndexPath(item: 0, section: 1)
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(), type: .circleStrokeSpin, color: .systemPurple, padding: 8.0)
    
    @IBOutlet private weak var sessionNotificationLabel: UILabel!
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
        updateSemifinalists()
    }
    
    //MARK:- • View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            firstLoad = false
        } else {
//            for cell in ratingCollectionView.visibleCells {
//                (cell as? RatingCell)?.pauseVideo()
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
//            (cell as? RatingCell)?.playerVC.player?.pause()
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
            guard let segueIndexPath = sender as? IndexPath else {
                print("Incorrect Profile Segue indexPath")
                return
            }
            
            let vc = segue.destination as! ProfileViewController
            vc.isPublic = true
            switch segueIndexPath.section {
            case 0:
                vc.userData = semifinalists[segueIndexPath.row].translatedToUserProfile()
                if let img = cachedSemifinalistsImages[segueIndexPath.row] { vc.cachedProfileImage = img }
            case 1:
                vc.userData = starsTop[segueIndexPath.row].translatedToUserProfile()
                if let img = cachedProfileImages[segueIndexPath.row] { vc.cachedProfileImage = img }
            default: break
            }
            
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
        updateSemifinalists()

        /// Refresh control is being dismissed at the end of updating the rating items
        //DispatchQueue.main.async {
       //     self.ratingCollectionView.refreshControl?.endRefreshing()
        //}
    }

    //MARK:- Update rating items
    private func updateRatingItems() {
        Rating.getRatingData(ofType: .topList) { (serverResult) in
            let headers = self.ratingCollectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader) as? [RatingCollectionViewHeader]
            headers?.forEach({ (header) in
                header.isHidden = false
            })
            
            //MARK:- Dismiss Refresh Control
            self.ratingCollectionView.refreshControl?.endRefreshing()
            self.loadingIndicator.stopAnimating()
            
            switch serverResult {
                //MARK:- Error Handling
            case .error(let error):
                print("Error: \(error)")
                if self.starsTop.count == 0 {
                    self.sessionNotificationLabel.showNotification(.serverError)
                    headers?.forEach({ (header) in header.isHidden = true })
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
                    self.loadAllProfileImages(for: newTop, atSection: 1)
                    self.sessionNotificationLabel.isHidden = true
                    headers?.forEach({ (header) in header.isHidden = false })

                    self.ratingCollectionView.reloadSections(IndexSet(arrayLiteral: 1))
                    self.autoPlay(at: IndexPath(item: 0, section: 1), delay: 0.5)
                } else {
                    headers?.forEach({ (header) in header.isHidden = true })
                    self.sessionNotificationLabel.showNotification(.zeroPeopleInRating)
                }
            }
        }
    }
    
    //MARK:- Update Semifinalists
    private func updateSemifinalists() {
        Rating.getRatingData(ofType: .semifinalists) { (sessionResult) in
            switch sessionResult {
            case let .error(error):
                print("Error: \(error)")
            case let .results(data):
                self.semifinalists = data
                self.cachedSemifinalistsImages = Array(repeating: nil, count: data.count)
                self.loadAllProfileImages(for: data, atSection: 0)
                self.sessionNotificationLabel.isHidden = true
                self.ratingCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
            }
        }
    }
}

extension RatingViewController {
    //MARK:- Configure Views
    private func configureViews() {
        cachedProfileImages = Array(repeating: nil, count: topNumber)
        cachedVideoUrls = Array(repeating: nil, count: topNumber)
        
        ratingCollectionView.collectionViewLayout = createLayout()
        ratingCollectionView.delegate = self
        ratingCollectionView.dataSource = self
        loadingIndicator.enableCentered(in: view)
        
        configureActivityView(dismissHandler: {
            self.downloadRequestXF?.cancel()
            self.ratingCollectionView.isUserInteractionEnabled = true
        })
    }
    
    //MARK:- Cache Video
    func cacheVideo(for user: RatingProfile, index: Int) {
        let video = user.video!.translatedToVideoType()
        CacheManager.shared.getFileWith(fileUrl: video.url) { (result) in
            switch result{
            case.success(let url):
                //print("caching for cell at row '\(index)' complete")
                self.cachedVideoUrls[index] = url
            case.failure(let sessionError):
                print(sessionError)
            }
        }
    }
    
    //MARK:- Load Profile Photo
    func loadProfileImage(for user: RatingProfile, indexPath: IndexPath) {
        guard let imageName = user.profilePhoto else {
            print("no profile photo")
            return
        }
        Profile.getProfileImage(name: imageName) { (result) in
            switch result {
            case.error(let error):
                print(error)
            case.results(let image):
                self.setProfileImage(image, at: indexPath)
            }
        }
    }
    
    //MARK:- Set Profile Image for Cell
    private func setProfileImage(_ image: UIImage?, at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            cachedSemifinalistsImages[indexPath.row] = image
            if let cell = ratingCollectionView.cellForItem(at: indexPath) as? SemifinalistCell {
                cell.profileImageView.image = image ?? IconsManager.getIcon(.personCircleFill)
            }
        case 1:
            cachedProfileImages[indexPath.row] = image
            if let cell = ratingCollectionView.cellForItem(at: indexPath) as? RatingCell {
                cell.profileImageView.image = image ?? IconsManager.getIcon(.personCircleFill)
            }
        default: break
        }
    }
    
    //MARK:- Load All Profile Images
    func loadAllProfileImages(for cells: [RatingProfile], atSection section: Int) {
        for (i, user) in cells.enumerated() {
            loadProfileImage(for: user, indexPath: IndexPath(item: i, section: section))
        }
    }
    
    //MARK:- Pause All Videos
    ///Pauses videos in all visible cells.
    func pauseAllVideos() {
        for cell in ratingCollectionView.visibleCells {
            (cell as? RatingCell)?.pauseVideo()
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
                if self.isCurrentlyVisible {
                    self.autoPlayAction(at: indexPath)
                }
            }
        //This is being done to increase efficency
        } else {
            autoPlayAction(at: indexPath)
        }
    }
    
    ///Firstly, stops videos at visible cells, then hides Play button and plays video at given indexPath with 'playVideo' method
    private func autoPlayAction(at indexPath: IndexPath) {
        for cell in self.ratingCollectionView.visibleCells {
            (cell as? RatingCell)?.pauseVideo()
        }
        if let cell = self.ratingCollectionView.cellForItem(at: indexPath) as? RatingCell {
            cell.playPauseButton.isHidden = true
            cell.playVideo()
        }
    }
    
}


//MARK:- UITabBarControllerDelegate
extension RatingViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 2 {
            self.ratingCollectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            autoPlay(at: IndexPath(item: 0, section: 1))
            visibleIndexPath = IndexPath(item: 0, section: 1)
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
            (cell as? RatingCell)?.pauseVideo()
        }
        if let cell = self.ratingCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? RatingCell {
            cell.playVideo()
        }
    }*/
}
