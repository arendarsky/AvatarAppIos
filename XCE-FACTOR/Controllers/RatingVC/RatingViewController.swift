//
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import AVKit
import NVActivityIndicatorView
import Amplitude

final class RatingViewController: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var infoButton: UIBarButtonItem!
    @IBOutlet private weak var sessionNotificationLabel: UILabel!
    @IBOutlet weak var ratingCollectionView: UICollectionView!

    // MARK: - Public Properties

    var semifinalists = [RatingProfile]()
    var cachedSemifinalistsImages = [UIImage?]()
    var starsTop = [RatingProfile]()
    var cachedProfileImages = [UIImage?]()
    var cachedVideoUrls = [URL?]()

    // MARK: - Private Properties

    private let topNumber = 50
    private var firstLoad = true
    private var visibleIndexPath = IndexPath(item: 0, section: 1)
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(),
                                                           type: .circleStrokeSpin,
                                                           color: .systemPurple,
                                                           padding: 8.0)

    // TODO: Инициализирвоать в билдере, при переписи на CleanSwift поправить
    private let profileManager = ProfileServicesManager(networkClient: NetworkClient())
    private let ratingManager = RatingManager(networkClient: NetworkClient())
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavBar()
        configureNavBar()
        configureViews()
        configureRefrechControl()

        updateRatingItems()
        updateSemifinalists()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            firstLoad = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.delegate = self
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        autoPlay(at: visibleIndexPath, delay: 0)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pauseAllVideos()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile from Rating" {
            guard let segueIndexPath = sender as? IndexPath else { return }
            
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
    
    // MARK: - Actions

    @objc private func infoButtonPressed(sender: UIBarButtonItem) {
        presentInfoViewController(with: navigationItem.title, infoAbout: .rating)
    }

    @objc private func handleRefreshControl() {
        //Refreshing Data
        updateRatingItems()
        updateSemifinalists()

        /// Refresh control is being dismissed at the end of updating the rating items
        //DispatchQueue.main.async {
       //     self.ratingCollectionView.refreshControl?.endRefreshing()
        //}
    }

    // MARK: - Public Methods

    func loadProfileImage(for user: RatingProfile, indexPath: IndexPath) {
        guard let imageName = user.profilePhoto else { return }
        profileManager.getImage(for: imageName) { result in
            switch result {
            case .success(let image):
                self.setProfileImage(image, at: indexPath)
            case .failure(let error):
                print(error)
            }
        }
    }

    func cacheVideo(for user: RatingProfile, index: Int) {
        let video = user.video!.translatedToVideoType()
        CacheManager.shared.getFileWith(fileUrl: video.url) { result in
            switch result {
            case .success(let url):
                //print("caching for cell at row '\(index)' complete")
                self.cachedVideoUrls[index] = url
            case .failure(let sessionError):
                print(sessionError)
            }
        }
    }
}

// MARK: - Private Methods

private extension RatingViewController {

    func configureNavBar() {
        infoButton.target = self
        infoButton.action = #selector(infoButtonPressed)
    }

    func configureViews() {
        cachedProfileImages = Array(repeating: nil, count: topNumber)
        cachedVideoUrls = Array(repeating: nil, count: topNumber)

        ratingCollectionView.register(UINib(nibName: "StoriesCell", bundle: nil),
                                      forCellWithReuseIdentifier: "StoriesCell")
        ratingCollectionView.collectionViewLayout = createLayout()
        ratingCollectionView.delegate = self
        ratingCollectionView.dataSource = self
        loadingIndicator.enableCentered(in: view)
        
        configureActivityView {
            self.downloadRequestXF?.cancel()
            self.ratingCollectionView.isUserInteractionEnabled = true
        }
    }

    func updateSemifinalists() {
        ratingManager.fetchSemifinalists { result in
            switch result {
            case .success(let semifinalistsRatings):
                self.semifinalists = semifinalistsRatings
                self.cachedSemifinalistsImages = Array(repeating: nil, count: semifinalistsRatings.count)
                self.loadAllProfileImages(for: semifinalistsRatings, at: 0)
                self.sessionNotificationLabel.isHidden = true
                self.ratingCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    func configureRefrechControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        ratingCollectionView.refreshControl = refreshControl
        
    }

    func updateRatingItems() {
        ratingManager.fetchRatings { result in
            let headers = self.ratingCollectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader) as? [RatingCollectionViewHeader]
            headers?.forEach { $0.isHidden = false }
            
            /// Dismiss Refresh Control
            self.ratingCollectionView.refreshControl?.endRefreshing()
            self.loadingIndicator.stopAnimating()

            switch result {
            case .success(let profileRatings):
                var newTop: [RatingProfile] = []
                var newVideoUrls: [URL?] = []
                
                for userInfo in profileRatings {
                    if let _ = userInfo.video, newTop.count < self.topNumber {
                        newTop.append(userInfo)
                        newVideoUrls.append(userInfo.video?.translatedToVideoType().url)
                    }
                }
                /// Update Users and Videos List
                if newTop.count > 0 {
                    self.starsTop = newTop
                    self.cachedVideoUrls = newVideoUrls
                    self.cachedProfileImages = Array(repeating: nil, count: self.topNumber)
                    self.loadAllProfileImages(for: newTop, at: 1)
                    self.sessionNotificationLabel.isHidden = true
                    headers?.forEach { $0.isHidden = false }

                    self.ratingCollectionView.reloadSections(IndexSet(arrayLiteral: 1))
                    self.autoPlay(at: IndexPath(item: 0, section: 1), delay: 0.5)
                } else {
                    headers?.forEach { $0.isHidden = true }
                    self.sessionNotificationLabel.showNotification(.zeroPeopleInRating)
                }
            case .failure:
                guard self.starsTop.count == 0 else { return }

                self.sessionNotificationLabel.showNotification(.serverError)
                headers?.forEach { $0.isHidden = true }
            }
        }
    }
    
    func setProfileImage(_ image: UIImage?, at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            cachedSemifinalistsImages[indexPath.row] = image
            if let cell = ratingCollectionView.cellForItem(at: indexPath) as? StoriesCell {
                cell.setImage(image)
            }
        case 1:
            cachedProfileImages[indexPath.row] = image
            if let cell = ratingCollectionView.cellForItem(at: indexPath) as? RatingCell {
                cell.profileImageView.image = image ?? IconsManager.getIcon(.personCircleFill)
            }
        default: break
        }
    }

    func loadAllProfileImages(for cells: [RatingProfile], at section: Int) {
        for (i, user) in cells.enumerated() {
            loadProfileImage(for: user, indexPath: IndexPath(item: i, section: section))
        }
    }

    ///Pauses videos in all visible cells.
    func pauseAllVideos() {
        for cell in ratingCollectionView.visibleCells {
            (cell as? RatingCell)?.pauseVideo()
        }
    }

    func autoPlayVideos() {
        var visibleRect = CGRect()

        visibleRect.origin = ratingCollectionView.contentOffset
        visibleRect.size = ratingCollectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        guard let indexPath = ratingCollectionView.indexPathForItem(at: visiblePoint), indexPath != visibleIndexPath else { return }
        visibleIndexPath = indexPath
        autoPlayAction(at: indexPath)
    }

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
    func autoPlayAction(at indexPath: IndexPath) {
        for cell in ratingCollectionView.visibleCells {
            (cell as? RatingCell)?.pauseVideo()
        }

        if let cell = ratingCollectionView.cellForItem(at: indexPath) as? RatingCell {
            cell.playPauseButton.isHidden = true
            cell.playVideo()
        }
    }
    
}

//MARK:- UI Tab Bar Controller Delegate

extension RatingViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            ratingCollectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            autoPlay(at: IndexPath(item: 0, section: 1))
            visibleIndexPath = IndexPath(item: 0, section: 1)
        }
    }
}

// MARK: - UI Scroll View Delegate

extension RatingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        autoPlayVideos()
    }

    /// Did End Dragging
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            autoPlayVideos()
//        }
//    }
    
    /// Did End Decelerating
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        autoPlayVideos()
//    }
    
    /// Did Scroll To Top
//    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
//        for cell in ratingCollectionView.visibleCells {
//            (cell as? RatingCell)?.pauseVideo()
//        }
//        if let cell = self.ratingCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? RatingCell {
//            cell.playVideo()
//        }
//    }
}
