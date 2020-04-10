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

class RatingViewController: UIViewController {

    //MARK:- Properties
    var firstLoad = true
    var index = 0
    private var starsTop = [RatingProfile]()
    private var cachedProfileImages: [UIImage?] = Array(repeating: nil, count: 20)
    private var isVideoViewConfigured = Array(repeating: false, count: 20)
    //private var playerVC = AVPlayerViewController()
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(), type: .circleStrokeSpin, color: .purple, padding: 8.0)
    
    @IBOutlet weak var ratingCollectionView: UICollectionView!
    
    //MARK:- Rating VC Lifecycle
    ///
    ///
    
    //MARK:- • View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        handlePossibleSoundError()
        
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
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).updateControls()
        }
        ///update rating every time user switches the tabs
        if !firstLoad {
            //updateRatingItems()
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
        Rating.getRatingData { (serverResult) in
            self.loadingIndicator.stopAnimating()
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert()
            case .results(let users):
                print("Received \(users.count) users")
                var newTop = [RatingProfile]()
                
                for userInfo in users {
                    if let _ = userInfo.video, newTop.count < 20 {
                        newTop.append(userInfo)
                    }
                }
                print("Users with at least one video: \(newTop.count)")
                if newTop.count > 0 {
                    self.starsTop = newTop
                    self.cachedProfileImages = Array(repeating: nil, count: 20)
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
        let item = starsTop[indexPath.row]

        //configure video views inside cells
        //print("count:", starsTop.count)
        print("index", indexPath.row)
        if !ratingCollectionView.refreshControl!.isRefreshing {
            //if !isVideoViewConfigured[indexPath.row] {
            configureCellVideoView(cell)
            cell.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            if let image = cachedProfileImages[indexPath.row] {
                cell.profileImageView.image = image
            }
            else if let imageName = starsTop[indexPath.row].profilePhoto {
                cell.profileImageView.setProfileImage(named: imageName) { (image) in
                    self.cachedProfileImages[indexPath.row] = image
                }
            }
            cell.nameLabel.text = item.name
            cell.positionLabel.text = String(indexPath.row + 1) + " место"
            cell.likesLabel.text = item.likesNumber.formattedToLikes()
            cell.descriptionLabel.text = item.description
            
            cell.configureVideoPlayer(user: item)
            cell.updatePlayPauseButtonImage()
            cell.updateControls()
            cell.playPauseButton.isHidden = false
            cell.delegate = self
            //cell.replayButton.isHidden = true
        }
        return cell
    }
    
    //MARK:- Did End Displaying Cell
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! RatingCell).pauseVideo()
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
    
    //MARK:- Did Select Item at Index Path
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "Profile from Rating", sender: nil)
    }
}

//MARK:- Rating Cell Delegate
extension RatingViewController: RatingCellDelegate {
    func ratingCellDidPressPlayButton(_ ratingCell: RatingCell) {
        for cell in ratingCollectionView.visibleCells {
            (cell as! RatingCell).pauseVideo()
        }
        //ratingCell play or pause
    }
    
}


extension RatingViewController {
    //MARK:- Configure Video View
    private func configureCellVideoView(_ cell: RatingCell) {
        cell.playerVC.view.frame = cell.videoView.bounds
        //fill video content in frame ⬇️
        cell.playerVC.videoGravity = .resizeAspectFill
        cell.playerVC.view.layer.masksToBounds = true
        cell.playerVC.view.layer.cornerRadius = 25
        cell.playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        if #available(iOS 13.0, *) {
            cell.playerVC.view.backgroundColor = .quaternarySystemFill
        } else {
            cell.playerVC.view.backgroundColor = .lightGray
        }

        //MARK:- insert player into videoView
        self.addChild(cell.playerVC)
        cell.playerVC.didMove(toParent: self)
        cell.videoView.insertSubview(cell.playerVC.view, belowSubview: cell.positionLabel)
        cell.videoView.backgroundColor = .clear
        
        cell.playerVC.entersFullScreenWhenPlaybackBegins = false
        cell.playerVC.showsPlaybackControls = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
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
