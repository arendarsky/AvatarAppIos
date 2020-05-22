//
//MARK: CastingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 28.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//
//MARK:- TODO:
/// Split CastingVC into several extensions or possibly classes in different .swift files.
/// Add Caching for Images (actually not only for Casting)

import UIKit
import AVKit
import NVActivityIndicatorView
import MediaPlayer
import Amplitude

class CastingViewController: XceFactorViewController {

    //MARK: Properties
    private let castingViewCornerRadius: CGFloat = 25
    
    private var firstLoad = true
    private var userId = 0
    
    var receivedVideo = Video()
    private var currentStar: CastingVideo?
    private var unwatchedStars = Set<CastingVideo>()
    private var ratedStars = Set<CastingVideo>()
    private var playerVC = AVPlayerViewController()
    
    private var loadingIndicator: NVActivityIndicatorView?
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var volumeObserver: Any?
    private var videoPlaybackErrorObserver: Any?
    //var noVideosLeft = false
    var isAppearingAfterFullVideo = false
    var shouldReload = false
    
    let backViewScale: CGFloat = 0.9
    let hapticsGenerator = UIImpactFeedbackGenerator()
    var castingCenter = CGPoint(x: 0, y: 0)
    var hapticsPerformed = false
    var imageBounced = false
    
    @IBOutlet weak var updateIndicator: NVActivityIndicatorView!
    @IBOutlet weak var castingView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var nextCastingView: UIView!
    @IBOutlet weak var indicatorImageView: UIImageView!
    
    @IBOutlet weak var starNameLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var starDescriptionLabel: UILabel!
    @IBOutlet weak var nextImageView: UIImageView!
    @IBOutlet weak var nextNameLabel: UILabel!
    
    @IBOutlet weak var castingMenuButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var videoGravityButton: UIButton!
    @IBOutlet weak var fullVideoButton: UIButton!
    
    @IBOutlet weak var addNewVideoButton: UIBarButtonItem!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var superLikeButton: UIButton!
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var updateButton: XceFactorWideButton!

    ///
//MARK:- CastingVC Lifecycle
    ///
    ///
    
    //MARK:- • View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCustomNavBar(isBorderHidden: true)
        
        presentOnboardingVC(relatedTo: Globals.isFirstAppLaunch)
        configureViews()
        enableLoadingIndicator()
        loadUnwatchedVideos()
        hideViewsAndNotificate(.both, with: .loadingNextVideo)
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
                starImageView.setProfileImage(named: currentStar?.profilePhoto)
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
                profileVC.shouldUpdateData = true
            }
        }
    }
    
    //MARK:- INFO PRESSED
    @IBAction func infoButtonPressed(_ sender: Any) {
        presentInfoViewController(
            withHeader: navigationItem.title,
            text: .casting)
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
        if let url = CacheManager.shared.getLocalIfExists(at: receivedVideo.url),
            url.lastPathComponent == receivedVideo.name {
                receivedVideo.url = url
                shouldReload = true
        }
        hideAllControls(animated: false)
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
        var fullVideoUrl = receivedVideo.url!
        if receivedVideo.name != fullVideoUrl.lastPathComponent {
            fullVideoUrl = currentStar!.video.translatedToVideoType().url!
        }
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
        setLike(isLike: false, animationSimulated: true)
    }
    //MARK:- ❗️Like & Dislike Buttons are ignoring server response
    ///due to some mistakes at the server side, we have to ignore setting like/dislike results now and load the next video
    ///however, the local errors are still being handled (e.g. no Internet connection)

    
    //MARK:- Like Button Pressed
    @IBAction private func likeButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        setLike(isLike: true, animationSimulated: true)
    }
    
    //MARK:- Setting Like Method
    ///- parameter animate: Used for simulating swipe when user presses like/dislike button
    func setLike(isLike: Bool, animationSimulated: Bool) {
        (likeButton.isEnabled, dislikeButton.isEnabled) = (false, false)

        //MARK:- Like/Dislike Log
        Amplitude.instance()?.logEvent(isLike ? "heart_button_tapped" : "x_button_tapped")
        
        hideAllControls()
        playerVC.player?.pause()
        enableLoadingIndicator()
        
        if !animationSimulated {
            //we don't have property 'nextStar' (CastingVideo), so we can't use 'updateCastingViewFields' method yet
            videoView.isHidden = true
            starNameLabel.text = nextNameLabel.text
            starImageView.image = nextImageView.image
        }

        //MARK:- Save info about rated video
        if let current = currentStar {
            ratedStars.insert(current)
        }
        
        //MARK:- Like request
        WebVideo.setLike(videoName: receivedVideo.name, isLike: isLike) { (isSuccess) in
            (self.likeButton.isEnabled, self.dislikeButton.isEnabled) = (true, true)

            if isSuccess {
                //MARK:- Load the next video only after successful like request
                if animationSimulated {
                    self.simulateSwipe(isLike ? .right : .left) {
                        self.loadNextVideo()
                    }
                } else {
                    self.loadNextVideo()
                }
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
    
    //MARK:- Add new video button pressed
    @IBAction func addVideoButtonPressed(_ sender: Any) {
        rightNavBarButtonPressed()
    }
    
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
        let shouldHide = !replayButton.isHidden
        updateControls()
        UIView.transition(with: videoView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.replayButton.isHidden = shouldHide
            self.fullVideoButton.isHidden = shouldHide
            self.muteButton.isHidden = shouldHide
            //self.videoGravityButton.isHidden = shouldHide
        }, completion: nil)
    }
    
    //MARK:- UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn(scale: 0.85)
    }
    
    //MARK:- UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
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
            
            videoView.insertSubview(loadingIndicator!, aboveSubview: muteButton)
            
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
    func loadNextVideo() {
        //self.hideViewsAndNotificate(.castingOnly, with: .loadingNextVideo, animated: true)
        unwatchedStars.subtract(ratedStars)
        
        if unwatchedStars.count > 0 {
            let curUser = self.unwatchedStars.removeFirst()
            currentStar = curUser
            userId = curUser.id
            updateCastingViewFields(with: curUser)
            configureVideoPlayer(with: self.receivedVideo.url)
            
            if let nextUser = self.unwatchedStars.first {
                updateNextCastingView(with: nextUser)
            } else {
                nextCastingView.isHidden = true
                loadUnwatchedVideos(andConfigureImmediately: false)
            }
            
            print("Unwatched videos left:", self.unwatchedStars.count)
            print("curr video url:", self.receivedVideo.url ?? "some url error")
        } else {
            loadUnwatchedVideos()
            receivedVideo.url = nil
            //currentStar = nil
        }
    }
    
    //MARK:- Load Unwatched Videos
    private func loadUnwatchedVideos(andConfigureImmediately: Bool = true, tryRestorePrevVideo: Bool = false) {
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
                self.unwatchedStars = Set(users)
                self.unwatchedStars.subtract(self.ratedStars)
                
                print("\(self.unwatchedStars.count) videos left to show")
                print("Current set of unwatched videos: \(self.unwatchedStars)")

                if tryRestorePrevVideo, let current = self.currentStar {
                    self.updateCastingViewFields(with: current)
                    self.configureVideoPlayer(with: self.receivedVideo.url)
                    self.showViews()
                    
                } else if self.unwatchedStars.count > 0 {
                    if andConfigureImmediately {
                        let curUser = self.unwatchedStars.removeFirst()
                        self.currentStar = curUser
                        self.userId = curUser.id
                        self.updateCastingViewFields(with: curUser)
                        self.configureVideoPlayer(with: self.receivedVideo.url)
                    }
                    
                    if let nextUser = self.unwatchedStars.first {
                        self.updateNextCastingView(with: nextUser)
                    } else {
                        self.nextCastingView.isHidden = true
                    }
                    
                } else {
                    //MARK:- No Videos Left
                    self.hideViewsAndNotificate(.both, with: .noVideosLeft)
                    self.receivedVideo.url = nil
                    self.currentStar = nil
                }
            }
        }
    }
    
    
    //MARK:- Update Casting View Fields
    private func updateCastingViewFields(with user: CastingVideo) {
        let profileDefaultIcon = IconsManager.getIcon(.personCircleFill)
        
        starNameLabel.text = user.name
        starDescriptionLabel.text = user.description
        receivedVideo = user.video.translatedToVideoType()
        
        starImageView.image = profileDefaultIcon
        if let imageName = user.profilePhoto {
            if nextImageView.image != profileDefaultIcon && !firstLoad {
                starImageView.image = nextImageView.image
            }
            //ensure that the image is correct
            starImageView.setProfileImage(named: imageName)
        }
        nextNameLabel.text = ""
        nextImageView.image = profileDefaultIcon
        
        showViews()
    }
    
    //MARK:- Update Next Casting View
    func updateNextCastingView(with user: CastingVideo) {
        nextImageView.image = IconsManager.getIcon(.personCircleFill)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.nextNameLabel.text = user.name
            //self.nextImageView.setProfileImage(named: user.profilePhoto)
        }
        nextCastingView.isHidden = false
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
        prepareForSwipes()
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
        castingMenuButton.dropShadow(color: .black, opacity: 0.8)
        castingCenter = CGPoint(x: view.center.x, y: castingView.center.y)
        starNameLabel.dropShadow(color: .black, opacity: 0.8)
        starDescriptionLabel.dropShadow(color: .black, shadowRadius: 3.0, opacity: 0.9)

        
        //MARK:- Add Tap Gesture Recognizers to Views
        starImageView.addTapGestureRecognizer {
            self.profileSegue()
        }
        starNameLabel.addTapGestureRecognizer {
            self.profileSegue()
        }
        
        configureVideoView()
        updateControls()
    }
    
    //MARK:- Show Video Author's Profile
    func profileSegue() {
        performSegue(withIdentifier: "Profile from Casting", sender: nil)
        
        //MARK:- Profile from Casting Log
        Amplitude.instance()?.logEvent("castingprofile_button_tapped")
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
            playerVC.view.backgroundColor = videoView.backgroundColor
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
        videoView.insertSubview(playerVC.view, belowSubview: muteButton)
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
        DispatchQueue.global(qos: .background).async {
            CacheManager.shared.getFileWith(fileUrl: url) { (result) in
                switch result {
                case.failure(let stringError): print(stringError)
                case.success(let cachedUrl):
                    //print("Caching Casting Video complete successfully")
                    DispatchQueue.main.async {
                        self.receivedVideo.url = cachedUrl
                    }
                    //self.cachedUrl = cachedUrl
                }
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
    func showViews(animated: Bool = false, duration: Double = 0.2) {
        UIView.transition(with: view, duration: animated ? duration : 0, options: .transitionCrossDissolve, animations: {
            self.buttonsView.isHidden = false
            self.castingView.isHidden = false
            self.nextCastingView.isHidden = false
            self.videoView.isHidden = false
            self.nextCastingView.isHidden = false
        }, completion: nil)
    }
    
    //MARK:- Hide Casting Views with Notification
    private enum NotificationType {
        case networkError
        case noVideosLeft
        case loadingNextVideo
        case other(NSMutableAttributedString)
    }
    
    private enum ViewsToHide {
        case both
        case castingOnly
    }
    
    private func hideViewsAndNotificate(_ viewsToHide: ViewsToHide, with attributedTextType: NotificationType, animated: Bool = false) {
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
            Вы посмотрели все видео в Кастинге. Лучшие из них вы можете пересмотреть в Рейтинге, а ещё можете загрузить своё
            """,
                attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0)])
            )
            
          //MARK:- Loading Next Video
        case .loadingNextVideo:
            attributedText = NSMutableAttributedString(string: "Загружаем видео...", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22.0)])
            updateButton.isHidden = true
            
            //MARK:- Other
        case .other(let attrString):
            attributedText = attrString
        }
        
        notificationLabel.attributedText = attributedText
        (updateButton.isHidden, notificationLabel.isHidden) = (false, false)
        
        var shouldHideButtons = true
        switch viewsToHide {
        case .both:
            shouldHideButtons = true
        case .castingOnly:
            shouldHideButtons = false
        }
        
        UIView.transition(with: view, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve, animations: {
            self.buttonsView.isHidden = shouldHideButtons
            self.castingView.isHidden = true
            self.nextCastingView.isHidden = true
        }, completion: nil)

        playerVC.player?.pause()
    }
    
    //MARK:- Hide All Controls
    func hideAllControls(animated: Bool = true) {
        UIView.transition(with: videoView, duration: animated ? 0.2 : 0.0, options: .transitionCrossDissolve, animations: {
            self.replayButton.isHidden = true
            self.videoGravityButton.isHidden = true
            self.fullVideoButton.isHidden = true
            if !Globals.isMuted {
                self.muteButton.isHidden = true
            }
        }, completion: nil)
    }
    
    //MARK:- Show Controls
    //not all actually
    func showControls() {
        replayButton.isHidden = false
        muteButton.isHidden = false
        fullVideoButton.isHidden = false
    }
    
    //MARK:- Turn Controls On/Off
    ///Use this method to disable controls when Casting View is being swiped
    func setControls(enabled: Bool) {
        replayButton.isEnabled = enabled
        muteButton.isEnabled = enabled
        fullVideoButton.isEnabled = enabled
        videoGravityButton.isEnabled = enabled
        hideAllControls()
    }
    
    //MARK:- Update Contols
    ///Update mute and gravity indicators' images with this method
    func updateControls() {
        let muteImg = Globals.isMuted ? IconsManager.getIcon(.mute) : IconsManager.getIcon(.sound)
        let gravImg = playerVC.videoGravity == .resizeAspectFill ? IconsManager.getIcon(.rectangleCompressVertical) : IconsManager.getIcon(.rectangleExpandVertical)
        
        videoGravityButton.setImage(gravImg, for: .normal)
        muteButton.setImage(muteImg, for: .normal)
    }
    
}

//MARK:- Tab Bar Controller Delegate
extension CastingViewController: UITabBarControllerDelegate {}
