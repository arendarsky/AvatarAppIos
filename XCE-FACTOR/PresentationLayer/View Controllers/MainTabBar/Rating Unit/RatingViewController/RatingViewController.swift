//
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import AVKit
import NVActivityIndicatorView
import Amplitude

protocol RatingCashProtocol {
    /// Установка начальных данных профиля
    /// - Parameters:
    ///   - ratingProfiles: Профили участников в определенной секции
    ///   - cachedImages: Фото профиля участников в определенной секции
    ///   - ratingType: Тип секции на экране рейтинга
    func setUserProfiles(ratingType: RatingViewController.RatingType,
                         ratingProfiles: [RatingProfile],
                         cachedImages: [UIImage?])
    func updateImage( _ image: UIImage?, ratingType: RatingViewController.RatingType, for index: Int)
    func getUserProfiles(for ratingType: RatingViewController.RatingType) -> [RatingProfile]
    func getImages(for ratingType: RatingViewController.RatingType) -> [UIImage?]
}

/// Протокол View Controller-а экрана Рейтинга
protocol RatingViewControllerProtocol: AnyObject {
    func displayItems(sections: [Int: RatingViewController.RatingType],
                      finalistModels: [StoriesCellModel],
                      semifinalModels: [StoriesCellModel],
                      topListModels: [RatingCellModel])

    func addSection(for type: RatingViewController.RatingType,
                    sections: [Int: RatingViewController.RatingType],
                    finalistModels: [StoriesCellModel],
                    semifinalModels: [StoriesCellModel])

    func hideLoadingActivity()

    func changeHeaders(isActive: Bool)

    func setProfileImage(_ image: UIImage, at index: Int, for type: RatingViewController.RatingType)

    func showError(_ notification: UIView.NotificationType)
}

/// View Controller экрана Рейтинга
final class RatingViewController: XceFactorViewController {
    
    /// Тип секции на экране рейтинга
    enum RatingType {
        case finalists      // Секция финалистов
        case semifinalists  // Секция полуфинаслистов
        case topList        // Сукция топ рейтинга
        
        func groupHeight(height: CGFloat) -> NSCollectionLayoutDimension {
            switch self {
            case .finalists, .semifinalists:
                return .estimated(80.0)
            case .topList:
                return .fractionalHeight(height > 800 ? 0.9 : 0.925)
            }
        }
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var sessionNotificationLabel: UILabel!
    @IBOutlet weak var ratingCollectionView: UICollectionView!

    // MARK: - Private Properties

    private var visibleIndexPath: IndexPath
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(),
                                                           type: .circleStrokeSpin,
                                                           color: .systemPurple,
                                                           padding: 8.0)
    private var sections: [Int: RatingType]
    private var finalistModels: [StoriesCellModel]
    private var semifinalModels: [StoriesCellModel]
    private var topListModels: [RatingCellModel]

    // TODO: Убрать из VC
    private var cachedVideoUrls: [URL?] = []

    // TODO: Пенести в интерактор и логику, которая испольщует эти менеджеры
    private let profileManager: ProfileServicesManagerProtocol
    private let ratingManager: RatingManagerProtocol

    private let interactor: RatingInteractorProtocol

    // MARK: - Init

    init(interactor: RatingInteractorProtocol,
         profileManager: ProfileServicesManagerProtocol,
         ratingManager: RatingManagerProtocol) {
        // Если нет финалистов/полуфиналистов
        visibleIndexPath = IndexPath(item: 0, section: 0)

        sections = [:]
        finalistModels = []
        semifinalModels = []
        topListModels = []
        
        self.interactor = interactor
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
        interactor.refreshData()

        /// Refresh control is being dismissed at the end of updating the rating items
        //DispatchQueue.main.async {
       //     self.ratingCollectionView.refreshControl?.endRefreshing()
        //}
    }

    // MARK: - Public Methods

    // TODO: В Interactor
    func cacheVideo(for userVideo: VideoWebData?, index: Int) {
        guard let video = userVideo?.translatedToVideoType() else { return }

        // TODO: Через протокол
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

// MARK: - RatingViewControllerProtocol

extension RatingViewController: RatingViewControllerProtocol {
    func addSection(for type: RatingType,
                    sections: [Int: RatingViewController.RatingType],
                    finalistModels: [StoriesCellModel],
                    semifinalModels: [StoriesCellModel]) {
        self.finalistModels = finalistModels
        self.semifinalModels = semifinalModels

        if self.sections.values.contains(type) {
            self.sections = sections
            guard let section = getSection(for: type) else { return }
            visibleIndexPath.section = sections.count - 1
            ratingCollectionView.reloadSections(IndexSet(arrayLiteral: section))
        } else {
            self.sections = sections
            guard let section = getSection(for: type) else { return }
            visibleIndexPath.section = sections.count - 1
            ratingCollectionView.insertSections(IndexSet(arrayLiteral: section))
        }
    }
    
    func displayItems(sections: [Int: RatingType],
                      finalistModels: [StoriesCellModel],
                      semifinalModels: [StoriesCellModel],
                      topListModels: [RatingCellModel]) {
        self.sections = sections
        self.finalistModels = finalistModels
        self.semifinalModels = semifinalModels
        self.topListModels = topListModels

        sessionNotificationLabel.isHidden = true

        visibleIndexPath.section = sections.count - 1
        ratingCollectionView.reloadData()
        // Включаем воспроизведение у первого участника
        autoPlay(at: visibleIndexPath, delay: 0.5)
    }
    
    func changeHeaders(isActive: Bool) {
        let headers = ratingCollectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader) as? [RatingCollectionViewHeader]
        headers?.forEach { $0.isHidden = isActive }
    }
    
    func hideLoadingActivity() {
        ratingCollectionView.refreshControl?.endRefreshing()
        loadingIndicator.stopAnimating()
    }

    func setProfileImage(_ image: UIImage, at index: Int, for type: RatingType) {
        guard let section = getSection(for: type) else { return }

        let indexPath = IndexPath(row: index, section: section)

        switch type {
        case .finalists:
            finalistModels[index].profileImage = image
        case .semifinalists:
            semifinalModels[index].profileImage = image
        case .topList:
            topListModels[index].profileImage = image
        }

        if let cell = ratingCollectionView.cellForItem(at: indexPath) as? StoriesCell {
            cell.setImage(image)
        } else if let cell = ratingCollectionView.cellForItem(at: indexPath) as? RatingCell {
            cell.profileImageView.image = image
        }
    }

    func showError(_ notification: UIView.NotificationType) {
        sessionNotificationLabel.showNotification(notification)
    }

    func getRatingType(for section: Int) -> RatingType? {
        return sections[section]
    }

    func getSection(for ratingType: RatingType) -> Int? {
        return sections.findKey(for: ratingType)
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
        cachedVideoUrls = Array(repeating: nil, count: RatingInteractor.topNumber)
        loadingIndicator.enableCentered(in: view)
        
        configureActivityView {
            self.downloadRequestXF?.cancel()
            self.ratingCollectionView.isUserInteractionEnabled = true
        }
    }

    func configureRefrechControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        ratingCollectionView.refreshControl = refreshControl
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
            autoPlay(at: visibleIndexPath)
        }
    }
}

// MARK: - UI Scroll View Delegate

extension RatingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        autoPlayVideos()
    }
}

// MARK: - UI Collection View Data Source

extension RatingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = getRatingType(for: section) else { fatalError("Undefined section") }
        
        switch sectionType {
        case .finalists:
            return finalistModels.count
        case .semifinalists:
            return semifinalModels.count
        case .topList:
            return topListModels.count
        }
    }
}

// MARK: - UI Collection View Delegate

extension RatingViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = getRatingType(for: indexPath.section) else { fatalError("Undefined section") }

        switch sectionType {
        case .finalists:
            let storyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell",
                                                               for: indexPath) as! StoriesCell
            storyCell.set(viewModel: finalistModels[indexPath.row])
            return storyCell
        case .semifinalists:
            let storyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell",
                                                               for: indexPath) as! StoriesCell
            storyCell.set(viewModel: semifinalModels[indexPath.row])
            return storyCell
        case .topList:
            let ratingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RatingCell",
                                                          for: indexPath) as! RatingCell
            // TODO: Объединить delegate and vc и убрать index
            ratingCell.set(viewModel: topListModels[indexPath.row],
                           cachedUrl: cachedVideoUrls[indexPath.row],
                           index: indexPath.row,
                           delegate: self, vc: self)

            // TODO: Убрать из логику из VC
            cacheVideo(for: topListModels[indexPath.row].video, index: indexPath.row)
            
            return ratingCell
        }
    }
    
    /// Did End Displaying Cell
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? RatingCell else { return }

        cell.pauseVideo()
        for visibleCell in ratingCollectionView.visibleCells {
            (visibleCell as? RatingCell)?.updateControls()
        }
    }
    
    /// Collection View Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       switch kind {
       case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: "RatingCollectionViewHeader",
                                                                                   for: indexPath) as? RatingCollectionViewHeader,
                let sectionType = getRatingType(for: indexPath.section) else { fatalError("Invalid view type or undefined section") }
            
            switch sectionType {
            case .finalists:
                headerView.sectionTitleLabel.text = "Финалисты"
            case .semifinalists:
                headerView.sectionTitleLabel.text = "Полуфиналисты"
            case .topList:
                headerView.sectionTitleLabel.text = "Топ-50"
            }

            //headerView.numberLabel.isHidden = sectionKind != .semifinalists
            headerView.numberLabel.text = ""//sectionKind == .semifinalists ? "\(self.semifinalists.count)" : ""

            return headerView

       default:
            assert(false, "Invalid element type")
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let ratingType = getRatingType(for: indexPath.section) else { return }
        interactor.processTransition(for: ratingType, in: indexPath.row)
    }
}

// MARK: - Rating Cell Delegate

extension RatingViewController: RatingCellDelegate {
    
    /// Did Press Play/Pause
    func ratingCellDidPressPlayButton(_ sender: RatingCell) {
        for cell in ratingCollectionView.visibleCells {
            guard let visibleCell = cell as? RatingCell else { return }
            if visibleCell != sender {
                visibleCell.pauseVideo()
            }
        }
    }
    
    // Did Press Mute Button
    func ratingCellDidPressMuteButton(_ sender: RatingCell) {
        for cell in ratingCollectionView.visibleCells {
            guard let visibleCell = cell as? RatingCell else { return }
            if visibleCell != sender {
                visibleCell.updateControls()
                if Globals.isMuted {
                    visibleCell.muteButton.isHidden = false
                }
            }
        }
    }
    
    // Did Tap On Profile
    func handleTapOnRatingCell(_ sender: RatingCell) {
        interactor.processTransition(for: .topList, in: sender.tag)
        
        // Profile from Rating Log
        Amplitude.instance()?.logEvent("ratingprofile_button_tapped")
    }
    
    /// Did Press Share Button
    func didPressShare(_ sender: RatingCell) {
        interactor.processSharing(for: .topList, in: sender.tag)
    }
    
    /// Failed To Load Video
    func ratingCellFailedToLoadVideo(_ sender: RatingCell) {
        sender.prepareForReload()
        sender.playVideo()
    }
}
