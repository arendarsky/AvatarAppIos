//
//MARK: CastingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 28.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import NVActivityIndicatorView
import MediaPlayer

class CastingViewController: XceFactorViewController {

    //MARK: Properties
    private let castingViewCornerRadius: CGFloat = 25
    
    private var firstLoad = true
    private var userId = 0
    
    private var receivedVideo = Video()
    private var receivedUsersInCasting = [CastingVideo]()
    private var playerVC = AVPlayerViewController()
    
    private var loadingIndicator: NVActivityIndicatorView?
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var volumeObserver: Any?
    private var videoPlaybackErrorObserver: Any?
    var isAppearingAfterFullVideo = false
    var shouldReload = false
    
    @IBOutlet weak var updateIndicator: NVActivityIndicatorView!
    @IBOutlet weak var castingView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var starNameLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var starDescriptionLabel: UILabel!
    
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var videoGravityButton: UIButton!
    @IBOutlet weak var fullVideoButton: UIButton!
    
    @IBOutlet weak var addNewVideoButton: UIBarButtonItem!
    
    @IBOutlet weak var bottomGradientView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var superLikeButton: UIButton!
    
    @IBOutlet weak var emptyVideoListLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!

    ///
//MARK:- CastingVC Lifecycle
    ///
    ///
    
    //MARK:- • View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        self.configureCustomNavBar(isBorderHidden: true)
        
        enableLoadingIndicator()
        
        //MARK:- Fetch Videos List
        loadUnwatchedVideos()
        
        ///custom button for large title in casting view
        //setupNavBarRightButton()
        configureViews()
    }
    
    //MARK:- • View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("User Videos Count: \(Globals.user.videosCount ?? 5)")
        addNewVideoButton.isEnabled = (Globals.user.videosCount ?? 5) < 4
        
        playerVC.player?.isMuted = Globals.isMuted
        updateControls()
        if Globals.isMuted {
            muteButton.isHidden = false
        }
        
        if firstLoad {
            firstLoad = false
        } else {
            loadingIndicator?.stopAnimating()
            if castingView.isHidden {
                loadUnwatchedVideos(tryRestorePrevVideo: true)
            } else {
                ///calling here to minimize adding/removing observers
                manageVideoPlaybackWhenAppearing()
            }
        }
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
        playerVC.player?.pause()
        removeAllObservers()
    }
    
    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile from Casting" {
            let vc = segue.destination as! ProfileViewController
            vc.isPublic = true
            vc.userData.id = userId
            vc.userData.name = starNameLabel.text ?? ""
            vc.userData.description = starDescriptionLabel.text
            if let img = starImageView.image { vc.cachedProfileImage = img }
        }
        else if segue.identifier == "Upload new video" {
            let navVC = segue.destination as? UINavigationController
            let vc = navVC?.viewControllers.first as? VideoPickVC
            vc?.shouldHideViews = true
            vc?.shouldHideBackButton = false
            vc?.isCastingInitiated = true
            if let profileNav = tabBarController?.viewControllers?.last as? UINavigationController,
                let profileVC = profileNav.viewControllers.first as? ProfileViewController {
                profileVC.isAppearingAfterUpload = true
            }
        }
    }
    
    //MARK:- Video Gravity Button Pressed
    @IBAction func gravityButtonPressed(_ sender: UIButton) {
        if playerVC.videoGravity == AVLayerVideoGravity.resizeAspectFill {
            playerVC.videoGravity = AVLayerVideoGravity.resizeAspect
            videoGravityButton.setImage(IconsManager.getIcon(.rectangleExpandVertical), for: .normal)
        } else {
            playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoGravityButton.setImage(IconsManager.getIcon(.rectangleCompressVertical), for: .normal)
        }
    }
    

    //MARK:- Mute Video Button Pressed
    @IBAction func muteButtonPressed(_ sender: UIButton) {
        if Globals.isMuted && firstLoad {
            sender.setViewWithAnimation(in: videoView, hidden: true, startDelay: 0.3, duration: 0.2)
        }
        Globals.isMuted = !Globals.isMuted
        playerVC.player?.isMuted = Globals.isMuted
        updateControls()
    }
    
    //MARK:- REPLAY Button Pressed
    @IBAction private func replayButtonPressed(_ sender: Any) {
        //reload if cached video exists, otherwise seek to startTime
        if let url = CacheManager.shared.getLocalIfExists(at: receivedVideo.url) {
            receivedVideo.url = url
            shouldReload = true
        }
        hideAllControls()
        replayAction()
    }
    
    func replayAction() {
        if shouldReload || loadingIndicator!.isAnimating {
            configureVideoPlayer(with: receivedVideo.url)
            shouldReload = false
        } else {
            playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1000))
            playerVC.player?.play()
            addAllObservers()
        }
        enableLoadingIndicator()
    }

    //MARK:- Full Video Button Pressed
    @IBAction private func fullVideoButtonPressed(_ sender: Any) {
        let timeToStart = playerVC.player?.currentTime().seconds ?? receivedVideo.startTime
        playerVC.player?.pause()
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1000))
        let fullVideoUrl = receivedVideo.url!
        let fullScreenPlayer = AVPlayer(url: fullVideoUrl)
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        fullScreenPlayerVC.player?.isMuted = Globals.isMuted
        fullScreenPlayerVC.player?.seek(to: CMTime(seconds: timeToStart, preferredTimescale: 1000))
        isAppearingAfterFullVideo = true
        
        handlePossibleSoundError()
        present(fullScreenPlayerVC, animated: true) {
            fullScreenPlayer.play()
        }
    }
    
    //MARK:- Dislike Button Pressed
    @IBAction private func dislikeButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        likeButton.isEnabled = false
        dislikeButton.isEnabled = false
        
        hideAllControls()
        playerVC.player?.pause()
        enableLoadingIndicator()
        
        WebVideo.setLike(videoName: receivedVideo.name, isLike: false) { (isSuccess) in
            self.likeButton.isEnabled = true
            self.dislikeButton.isEnabled = true
            
            if isSuccess {
                self.loadNextVideo()
                print("Videos left:", self.receivedUsersInCasting.count)
                print("curr video url:", self.receivedVideo.url ?? "some url error")
            } else {
                self.hideViewsAndNotificate(.both, with: .networkError)
            }
        }
        //MARK:-❗️Like & Dislike Buttons are ignoring server response
        ///due to some mistakes at the server side, we have to ignore setting like/dislike results now and load the next video
        ///however, the local errors are still being handled (e.g. no Internet connection)

    }
    
    //MARK:- Like Button Pressed
    @IBAction private func likeButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        likeButton.isEnabled = false
        dislikeButton.isEnabled = false
        
        hideAllControls()
        playerVC.player?.pause()
        enableLoadingIndicator()
        
        WebVideo.setLike(videoName: receivedVideo.name, isLike: true) { (isSuccess) in
            self.likeButton.isEnabled = true
            self.dislikeButton.isEnabled = true
            
            if isSuccess {
                self.loadNextVideo()
                print("Videos left:", self.receivedUsersInCasting.count)
                print("curr video url:", self.receivedVideo.url ?? "some url error")
            } else {
                self.hideViewsAndNotificate(.both, with: .networkError)
            }
        }
    }
    
    //MARK: Super Like Button Pressed
    @IBAction func superLikeButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        performSegue(withIdentifier: "Show MessageVC", sender: sender)
    }
    
    @IBAction func addVideoButtonPressed(_ sender: Any) {
        rightNavBarButtonPressed()
    }
    
    //MARK:- UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn(scale: 0.85)
    }
    
    //MARK:- UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
    
    
    //MARK:- Add new video button pressed
    @objc private func rightNavBarButtonPressed() {
        //print("button tapped")
        playerVC.player?.pause()
        replayButton.isHidden = false
        performSegue(withIdentifier: "Upload new video", sender: nil)
        replayButton.isHidden = false
    }
    
    //MARK:- Update Button Pressed
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        loadUnwatchedVideos(tryRestorePrevVideo: true)
        updateIndicator.startAnimating()
    }
    
    //MARK:- DoubleTap on VideoView
    @objc func handleDoubleTap() {
        playerVC.videoGravity = playerVC.videoGravity == AVLayerVideoGravity.resizeAspect ? .resizeAspectFill : .resizeAspect
        updateControls()
    }
    
    //MARK:- Single Tap on VideoView
    @objc func handleOneTap() {
        replayButton.setViewWithAnimation(in: self.videoView, hidden: !self.replayButton.isHidden, duration: 0.2)
        //videoGravityButton.setViewWithAnimation(in: self.videoView, hidden: !self.replayButton.isHidden, duration: 0.2)
        fullVideoButton.setViewWithAnimation(in: self.videoView, hidden: !self.replayButton.isHidden, duration: 0.2)
        muteButton.setViewWithAnimation(in: self.videoView, hidden: !self.replayButton.isHidden, duration: 0.2)
        updateControls()
    }

}

//MARK:- ❗️Casting VC Configurations
///
///
extension CastingViewController {
    //MARK:- Enable Loading Indictator
    private func enableLoadingIndicator() {
        if loadingIndicator == nil {
            let width: CGFloat = 50.0
            let frame = CGRect(x: (videoView.bounds.midX - width/2), y: (videoView.bounds.midY - width/2), width: width, height: width)
            
            loadingIndicator = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .white, padding: 4.0)
            loadingIndicator!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loadingIndicator!.layer.cornerRadius = width / 2
            
            videoView.insertSubview(loadingIndicator!, aboveSubview: starImageView)
            
            //MARK:- constraints: center spinner vertically and horizontally in video view
            loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loadingIndicator!.heightAnchor.constraint(equalToConstant: loadingIndicator!.frame.height),
                loadingIndicator!.widthAnchor.constraint(equalToConstant: loadingIndicator!.frame.width),
                loadingIndicator!.centerYAnchor.constraint(equalTo: videoView.centerYAnchor),
                loadingIndicator!.centerXAnchor.constraint(equalTo: videoView.centerXAnchor)
            ])
        }
        loadingIndicator!.startAnimating()
        loadingIndicator!.isHidden = false
    }
    
    //MARK:- Manage Video Playback When Appearing
    private func manageVideoPlaybackWhenAppearing() {
        if isAppearingAfterFullVideo {
            playerVC.player?.pause()
            showControls()
            isAppearingAfterFullVideo = false
        } else if let time = playerVC.player?.currentTime().seconds, time > receivedVideo.endTime {
            //replayAction()
            playerVC.player?.pause()
            showControls()
        }
        else {
            playerVC.player?.play()
        }
        addAllObservers()
    }
    
   //MARK:- Load Next Video in Casting
    private func loadNextVideo() {
        //self.hideViewsAndNotificate(.castingOnly, with: .loadingNextVideo, animated: true)
        if receivedUsersInCasting.count > 0 {
            let curUser = self.receivedUsersInCasting.removeLast()
            userId = curUser.id
            updateCastingViewFields(with: curUser)
            self.configureVideoPlayer(with: self.receivedVideo.url)
        } else {
            receivedVideo.url = nil
            loadUnwatchedVideos()
        }
    }
    
    //MARK:- Load Unwatched Videos
    private func loadUnwatchedVideos(tryRestorePrevVideo: Bool = false) {
        WebVideo.getUnwatched { (serverResult) in
            self.updateIndicator.stopAnimating()
            
            switch serverResult {
            //MARK:- Network Error
            case .error(let error):
                print("Server error: \(error)")
                self.hideViewsAndNotificate(.both, with: .networkError)
                break
                
            //MARK:- Results
            case .results(let users):
                if tryRestorePrevVideo, let url = self.receivedVideo.url {
                    self.configureVideoPlayer(with: url)
                    self.showViews()
                    
                } else if users.count > 0 {
                    self.receivedUsersInCasting = users
                    print("Received \(self.receivedUsersInCasting.count) videos to show")
                    
                    let curUser = self.receivedUsersInCasting.removeLast()
                    self.userId = curUser.id
                    self.updateCastingViewFields(with: curUser)
                    self.configureVideoPlayer(with: self.receivedVideo.url)
                    
                } else {
                    //MARK:- No Videos Left
                    self.hideViewsAndNotificate(.both, with: .noVideosLeft)
                }
            }
        }
    }
    
    
    //MARK:- Update Casting View Fields
    private func updateCastingViewFields(with user: CastingVideo) {
        self.starNameLabel.text = user.name
        self.starDescriptionLabel.text = user.description
        self.receivedVideo = user.video.translatedToVideoType()
        starImageView.image = IconsManager.getIcon(.personCircleFill)
        if let imageName = user.profilePhoto {
            self.starImageView.setProfileImage(named: imageName)
        }
        showViews()
    }
    
    
    //MARK:- Configure Views
    private func configureViews() {
        //likeButton.addBlur()
        //dislikeButton.addBlur()
        let radius: CGFloat = 10.0
        let opacity: Float = 0.6
        let sColor = UIColor.black

        likeButton.dropShadow(color: sColor, shadowRadius: radius, opacity: opacity, forceBackground: false)
        dislikeButton.dropShadow(color: sColor, shadowRadius: radius, opacity: opacity, forceBackground: false)
        //superLikeButton.dropShadow()
        replayButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        replayButton.isHidden = true
        muteButton.backgroundColor = replayButton.backgroundColor
        videoGravityButton.backgroundColor = replayButton.backgroundColor
        fullVideoButton.backgroundColor = replayButton.backgroundColor
        
        //MARK:- Mute CastingVC at load
        ///NOW the whole app is being muted at LoadingViewController 
        //Globals.isMuted = true
        muteButton.isHidden = !Globals.isMuted
        
        castingView.layer.cornerRadius = castingViewCornerRadius
        castingView.dropShadow()
        starNameLabel.dropShadow(color: .black, opacity: 0.8)
        starDescriptionLabel.dropShadow(color: .black, shadowRadius: 3.0, opacity: 0.9)

        
        //MARK:- Add Tap Gesture Recognizers to Views
        starImageView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "Profile from Casting", sender: nil)
        }
        starNameLabel.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "Profile from Casting", sender: nil)
        }
        
        configureVideoView()
        updateControls()
    }
    
    
    //MARK:- Configure Video View
    private func configureVideoView() {
    
        playerVC.view.frame = videoView.bounds
        //fill video content in frame ⬇️
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = castingViewCornerRadius
        //playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        if #available(iOS 13.0, *) {
            playerVC.view.backgroundColor = .quaternarySystemFill
        } else {
            let playerColor = UIColor.darkGray.withAlphaComponent(0.5)
            playerVC.view.backgroundColor = playerColor
            videoView.backgroundColor = playerColor
            replayButton.setImage(IconsManager.getIcon(.repeatAction), for: .normal)
            fullVideoButton.setImage(IconsManager.getIcon(.expandCorners), for: .normal)
        }
        playerVC.showsPlaybackControls = false
        
        //MARK:- insert player into videoView
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.insertSubview(playerVC.view, belowSubview: starImageView)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
        
        //MARK:- One-Tap Gesture Recognizer for Video View
        let oneTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOneTap))
        oneTapRecognizer.numberOfTapsRequired = 1
        videoView.addGestureRecognizer(oneTapRecognizer)
        let doubleTapRecongnizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRecongnizer.numberOfTapsRequired = 2
        videoView.addGestureRecognizer(doubleTapRecongnizer)
        oneTapRecognizer.require(toFail: doubleTapRecongnizer)
    }
    
    //MARK:- Cache Video
    func cacheVideo(with url: URL?) {
        CacheManager.shared.getFileWith(fileUrl: url) { (result) in
            switch result {
            case.failure(let stringError): print(stringError)
            case.success(let cachedUrl):
                //print("Caching Casting Video complete successfully")
                self.receivedVideo.url = cachedUrl
                //self.cachedUrl = cachedUrl
            }
        }
    }
    
   //MARK:- Configure Video Player
    private func configureVideoPlayer(with videoUrl: URL?) {
        guard let url = videoUrl else {
            print("invalid url. cannot play video")
            shouldReload = true
            return
        }
        removeAllObservers()
        //MARK:- • Load local video if exists
        if let cachedUrl = CacheManager.shared.getLocalIfExists(at: url) {
            playerVC.player = AVPlayer(url: cachedUrl)
            receivedVideo.url = cachedUrl
            //self.cachedUrl = cachedUrl
        } else {
            playerVC.player = AVPlayer(url: url)
            cacheVideo(with: url)
        }

        //MARK: • present video from specified point:
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1000))
        playerVC.player?.isMuted = Globals.isMuted
        addAllObservers()
        replayButton.isHidden = true
        playerVC.player?.play()
        enableLoadingIndicator()
    }
    
    
    //MARK:- Remove All Observers
    private func removeAllObservers() {
        if let timeObserver = videoTimeObserver {
            //removing time obse
            playerVC.player?.removeTimeObserver(timeObserver)
            videoTimeObserver = nil
        }
        if videoDidEndPlayingObserver != nil || volumeObserver != nil {
            NotificationCenter.default.removeObserver(self)
            videoDidEndPlayingObserver = nil
            volumeObserver = nil
            videoPlaybackErrorObserver = nil
        }
    }
    
    //MARK:- Add All Observers
    private func addAllObservers() {
        removeAllObservers()
        
        var timeAfterReplayButtonBecameVisible = 0
        //MARK:- Video Periodic Time Observer
        let interval = CMTimeMake(value: 1, timescale: 100)
        videoTimeObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            
            //MARK:- Hide Controls Automatically
            timeAfterReplayButtonBecameVisible = timeAfterReplayButtonBecameVisible.countDeadline(
                deadline: 150, deadline2: 170,
                condition: self!.replayButton.isHidden && self!.fullVideoButton.isHidden,
                handler: {
                    self!.replayButton.setViewWithAnimation(in: self!.videoView, hidden: true, duration: 0.2)
            }, handler2: {
                self!.fullVideoButton.setViewWithAnimation(in: self!.videoView, hidden: true, duration: 0.2)
                if !Globals.isMuted {
                    self!.muteButton.setViewWithAnimation(in: self!.videoView, hidden: true, duration: 0.2)
                }
            })
            //print("time: \(timeAfterReplayButtonBecameVisible)")
            
            //MARK:- • manage current video time.
            // (Can also make progressView for showing as a video progress from here later)
            let currentTime = CMTimeGetSeconds(time)
            //self?.receivedVideo.currentTime = currentTime
            //print(currentTime)
            if abs(currentTime - self!.receivedVideo.endTime) <= 0.01 {
                //self?.replayAction()
                self?.playerVC.player?.pause()
                self?.showControls()
            } else {
                if currentTime >= self!.receivedVideo.endTime {
                    //self?.replayAction()
                    self?.playerVC.player?.pause()
                    self?.showControls()
                }
                //self?.disableLoadingIndicator()
                //self?.replayButton.isHidden = true
            }
            
            //MARK:- • enable loading indicator when player is loading
            self?.shouldReload = false
            if (self?.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp)! {
                self?.loadingIndicator?.stopAnimating()
            } else {
                self?.enableLoadingIndicator()
            }

            if (self?.playerVC.player?.currentItem?.isPlaybackBufferEmpty)! {
                self?.enableLoadingIndicator()
            }else {
                self?.loadingIndicator?.stopAnimating()
            }
            
            switch self?.playerVC.player?.currentItem?.status{
            case .failed:
                //self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                self?.shouldReload = true
                self?.replayButton.isHidden = false
            default:
                //self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                break
            }
        }
        
        //MARK:- Notification Center Observers
        videoDidEndPlayingObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerVC.player?.currentItem)
        
        videoPlaybackErrorObserver = NotificationCenter.default.addObserver(self, selector: #selector(videoError), name: .AVPlayerItemNewErrorLogEntry, object: self.playerVC.player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(videoError), name: .AVPlayerItemFailedToPlayToEndTime, object: self.playerVC.player?.currentItem)
        
        volumeObserver = NotificationCenter.default.addObserver(self, selector: #selector(volumeDidChange(_:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    //MARK: Video Did End
    @objc private func videoDidEnd() {
        showControls()
    }
    
    //MARK:- Video Playback Error
    @objc private func videoError() {
        replayButton.isHidden = false
        shouldReload = true
    }
    
    //MARK:- Volume Did Change
    @objc func volumeDidChange(_ notification: NSNotification) {
        guard
            let info = notification.userInfo,
            let reason = info["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String,
            reason == "ExplicitVolumeChange" else { return }

        Globals.isMuted = false
        playerVC.player?.isMuted = Globals.isMuted
        if playerVC.player?.timeControlStatus == .playing {
            muteButton.setViewWithAnimation(in: self.videoView, hidden: true, startDelay: 0.2, duration: 0.2)
        }
        updateControls()
    }
    
    //MARK:- Setting Up Right Button in NavBar
    //preferred solution using UIButton but with some minuses
    private func setupNavBarRightButton() {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        let rightButton = UIButton()

        rightButton.setBackgroundImage(UIImage(named: "plus128.png"), for: .normal)
        rightButton.imageView?.tintColor = .systemBlue
        rightButton.imageView?.contentMode = .scaleAspectFit
        
        rightButton.addTarget(self, action: #selector(rightNavBarButtonPressed), for: .touchUpInside)
        
        navigationBar.addSubview(rightButton)
        rightButton.tag = 1
        let heightConst: CGFloat = 32
        rightButton.frame = CGRect(x: self.view.frame.width, y: 0, width: heightConst, height: heightConst)
        rightButton.clipsToBounds = true
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -16),
            rightButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -12),
            rightButton.heightAnchor.constraint(equalToConstant: heightConst),
            rightButton.widthAnchor.constraint(equalTo: rightButton.heightAnchor)
        ])
    
    }
    
    //MARK:- Show Casting Views
    func showViews(animated: Bool = false) {
        if animated {
            buttonsView.setViewWithAnimation(in: view, hidden: false, startDelay: 0.0, duration: 0.3)
            castingView.setViewWithAnimation(in: view, hidden: false, startDelay: 0.0, duration: 0.3)
        } else {
            buttonsView.isHidden = false
            castingView.isHidden = false
        }
    }
    
    //MARK:- Hide Casting Views with Notification
    enum NotificationType {
        case networkError
        case noVideosLeft
        case loadingNextVideo
        case other(NSMutableAttributedString)
    }
    
    enum HideType {
        case both
        case castingOnly
    }
    
    func hideViewsAndNotificate(_ viewsToHide: HideType, with attributedTextType: NotificationType, animated: Bool = false) {
        var attributedText = NSMutableAttributedString(string: "")
        
        switch attributedTextType {
            //MARK:- Network Error
        case .networkError:
            attributedText = NSMutableAttributedString(string: "Не удалось связаться с сервером\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28.0)])
            attributedText.append(
                NSMutableAttributedString(string: """
            \nПроверьте подключение к интернету и обновите окно
            """,
                attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0)])
            )
            
            //MARK:- No Videos Left
        case .noVideosLeft:
            attributedText = NSMutableAttributedString(string: "Ого!\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28.0)])
            attributedText.append(
                NSMutableAttributedString(string: """
            Вы посмотрели все видео в кастинге. Лучшие из них вы можете пересмотреть в разделе "Рейтинг", а ещё можете загрузить своё
            """,
                attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0)])
            )
            
          //MARK:- Loading Next Video
        case .loadingNextVideo:
            attributedText = NSMutableAttributedString(string: "Загрузка\nследующего видео", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22.0)])
            
            //MARK:- Other
        case .other(let attrString):
            attributedText = attrString
        }
        
        emptyVideoListLabel.attributedText = attributedText
        
        var shouldHideButtons = true
        switch viewsToHide {
        case .both:
            shouldHideButtons = true
        case .castingOnly:
            shouldHideButtons = false
        }
        
        if animated {
            castingView.setViewWithAnimation(in: view, hidden: true, startDelay: 0.0, duration: 0.3)
            buttonsView.setViewWithAnimation(in: view, hidden: shouldHideButtons, startDelay: 0.0, duration: 0.3)
        } else {
            self.castingView.isHidden = true
            self.buttonsView.isHidden = shouldHideButtons
        }
        playerVC.player?.pause()
    }
    
    //MARK:- Hide All Controls
    func hideAllControls() {
        replayButton.isHidden = true
        videoGravityButton.isHidden = true
        fullVideoButton.isHidden = true
        if !Globals.isMuted {
            muteButton.isHidden = true
        }
    }
    
    //MARK:- Show Controls
    //not all actually
    func showControls() {
        replayButton.isHidden = false
        muteButton.isHidden = false
        fullVideoButton.isHidden = false
    }
    
    //MARK:- Update Contol Buttons Images
    func updateControls() {
        let muteImg = Globals.isMuted ? IconsManager.getIcon(.mute) : IconsManager.getIcon(.sound)
        let gravImg = playerVC.videoGravity == .resizeAspectFill ? IconsManager.getIcon(.rectangleCompressVertical) : IconsManager.getIcon(.rectangleExpandVertical)
        
        videoGravityButton.setImage(gravImg, for: .normal)
        muteButton.setImage(muteImg, for: .normal)
    }
    
}

//MARK:- Tab Bar Controller Delegate
extension CastingViewController: UITabBarControllerDelegate {}
