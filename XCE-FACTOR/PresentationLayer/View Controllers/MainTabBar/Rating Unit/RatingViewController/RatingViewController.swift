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

    enum SectionKind: Int {
//        case finalists      // Секция финалистов
        case semifinalists  // Секция полуфинаслистов
        case topList        // Сукция топ рейтинга
        
        func groupHeight(height: CGFloat) -> NSCollectionLayoutDimension {
            switch self {
            case .semifinalists:
                return .estimated(80.0)
            case .topList:
                return .fractionalHeight(height > 800 ? 0.9 : 0.925)
            }
        }
        
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var sessionNotificationLabel: UILabel!
    @IBOutlet weak var ratingCollectionView: UICollectionView!

    // MARK: - Public Properties

    var finalists = [RatingProfile]()
    var semifinalists = [RatingProfile]()
    var starsTop = [RatingProfile]()

    var cachedSemifinalistsImages = [UIImage?]()
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

    // TODO: Пенести в интерактор и логику, которая испольщует эти менеджеры
    private let profileManager: ProfileServicesManagerProtocol
    private let ratingManager: RatingManagerProtocol

    private let interactor: RatingInteractorProtocol
    // TODO: Перенести RatingCollectioView и RatingCellDelegate сюда и заменить на private
    // Пененести при этом логику в interactor и presenter, чтобы разгрузить логику
    let router: RatingRouterProtocol

    // MARK: - Init

    init(interactor: RatingInteractorProtocol,
         router: RatingRouterProtocol,
         profileManager: ProfileServicesManagerProtocol,
         ratingManager: RatingManagerProtocol) {
        self.interactor = interactor
        self.router = router
        self.profileManager = profileManager
        self.ratingManager = ratingManager
        super.init(nibName: "RatingViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureCustomNavBar()
        configureCollectionView()
        configureViews()
        configureRefrechControl()

        interactor.setupInitialData()
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
        guard let video = user.video?.translatedToVideoType() else { return }

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
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Рейтинг"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(infoButtonPressed))
    }

    func configureCollectionView() {
        ratingCollectionView.collectionViewLayout = createLayout()
        ratingCollectionView.delegate = self
        ratingCollectionView.dataSource = self

        ratingCollectionView.register(UINib(nibName: "RatingCollectionViewHeader", bundle: nil),
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                      withReuseIdentifier: "RatingCollectionViewHeader")
        ratingCollectionView.register(UINib(nibName: "RatingCell", bundle: nil),
                                      forCellWithReuseIdentifier: "RatingCell")
        ratingCollectionView.register(UINib(nibName: "StoriesCell", bundle: nil),
                                      forCellWithReuseIdentifier: "StoriesCell")
    }

    func configureViews() {
        cachedProfileImages = Array(repeating: nil, count: topNumber)
        cachedVideoUrls = Array(repeating: nil, count: topNumber)

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
                self.ratingCollectionView.insertSections(IndexSet(arrayLiteral: 0))
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
                    self.ratingCollectionView.reloadSections(IndexSet(arrayLiteral: self.ratingCollectionView.numberOfSections - 1))
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

// MARK: - UI Tab Bar Controller Delegate

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
}
