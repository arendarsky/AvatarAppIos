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
//import WebKit
//import MobileCoreServices

class CastingViewController: UIViewController {

    //MARK: Properties
    private var firstLoad = true
    private var userId = 0
    
    private var testURL = "https://v.pinimg.com/videos/720p/77/4f/21/774f219598dde62c33389469f5c1b5d1.mp4"
    private var receivedVideo = Video()
    private var receivedUsersInCasting = [CastingVideo]()
    //var serverURL: URL?
    //var player = AVPlayer(url: self.serverURL!)
    private var playerVC = AVPlayerViewController()
    private var loadingIndicator: NVActivityIndicatorView?
    private var addVideoButtonImageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    var shouldReload = false
    
    //@IBOutlet weak var videoWebView: WKWebView!
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
        self.configureCustomNavBar()
        
        handlePossibleSoundError()
        enableLoadingIndicator()

        self.receivedVideo = Video(stringUrl: self.testURL, length: 30, startTime: 0, endTime: 30)
        
        //MARK:- Fetch Videos List
        updateVideosInCasting()
        
        ///custom button for large title in casting view
        //setupNavBarRightButton()
        configureViews()
        configureVideoView()
        
        //MARK:- Add Tap Gesture Recognizers to Views
        starImageView.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "Profile from Casting", sender: nil)
        }
        starNameLabel.addTapGestureRecognizer {
            self.performSegue(withIdentifier: "Profile from Casting", sender: nil)
        }
    }
    
    //MARK:- • View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("User Videos Count: \(Globals.user.videosCount ?? 5)")
        addNewVideoButton.isEnabled = (Globals.user.videosCount ?? 5) < 4
        
        playerVC.player?.isMuted = Globals.isMuted
        updateControls()
        
        if firstLoad {
            firstLoad = false
        } else {
            replayButton.isHidden = false
            loadingIndicator?.stopAnimating()
            if castingView.isHidden {
                updateVideosInCasting()
            }
        }
        //playerVC.player?.play()
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

    }
    
    //MARK:- • Did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeVideoObserver()
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
        }
    }
    
    //MARK:- Video Gravity Button Pressed
    @IBAction func gravityButtonPressed(_ sender: UIButton) {
        if playerVC.videoGravity == AVLayerVideoGravity.resizeAspectFill {
            playerVC.videoGravity = AVLayerVideoGravity.resizeAspect
            videoGravityButton.setImage(UIImage(systemName: "rectangle.expand.vertical"), for: .normal)
        } else {
            playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoGravityButton.setImage(UIImage(systemName: "rectangle.compress.vertical"), for: .normal)
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
        shouldReload = false
        hideAllControls()
        enableLoadingIndicator()

        if shouldReload {
            configureVideoPlayer(with: receivedVideo.url)
        } else {
            playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1000))
            playerVC.player?.play()
            addVideoObserver()
        }
    }

    //MARK:- Full Video Button Pressed
    @IBAction private func fullVideoButtonPressed(_ sender: Any) {
        playerVC.player?.pause()
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1000))
        let fullScreenPlayer = AVPlayer(url: receivedVideo.url!)
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        fullScreenPlayerVC.player?.isMuted = Globals.isMuted
        fullScreenPlayerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1000))
        
        present(fullScreenPlayerVC, animated: true) {
            fullScreenPlayer.play()
        }
    }
    
    //MARK:- Dislike Button Pressed
    @IBAction private func dislikeButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        
        hideAllControls()
        playerVC.player?.pause()
        enableLoadingIndicator()
        
        WebVideo.setLike(videoName: receivedVideo.name, isLike: false) { (isSuccess) in
            if isSuccess {
                self.updateVideosInCasting()
                print("Videos left:", self.receivedUsersInCasting.count)
                print("curr video url:", self.receivedVideo.url ?? "some url error")
            } else {
                self.hideViewsAndNotificate(.both, with: .networkError)
            }
        }

    }
    
    //MARK:- Like Button Pressed
    @IBAction private func likeButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        
        hideAllControls()
        playerVC.player?.pause()
        enableLoadingIndicator()
        
        WebVideo.setLike(videoName: receivedVideo.name, isLike: true) { (isSuccess) in
            if isSuccess {
                self.updateVideosInCasting()
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
        if receivedUsersInCasting.count == 0 {
            updateVideosInCasting()
        } else {
            configureVideoPlayer(with: receivedVideo.url)
            showViews()
        }
    }
    
    //MARK:- DoubleTap on VideoView
    @objc func handleDoubleTap() {
        playerVC.videoGravity = playerVC.videoGravity == AVLayerVideoGravity.resizeAspect ? .resizeAspectFill : .resizeAspect
        updateControls()
    }
    
    //MARK:- Single Tap on VideoView
    @objc func handleOneTap() {
        replayButton.setViewWithAnimation(in: self.videoView, hidden: !self.replayButton.isHidden, duration: 0.2)
        muteButton.setViewWithAnimation(in: self.videoView, hidden: !self.replayButton.isHidden, duration: 0.2)
        //videoGravityButton.setViewWithAnimation(in: self.videoView, hidden: !self.replayButton.isHidden, duration: 0.2)
        fullVideoButton.setViewWithAnimation(in: self.videoView, hidden: !self.replayButton.isHidden, duration: 0.2)
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
            
            videoView.insertSubview(loadingIndicator!, belowSubview: replayButton)
            
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
    
   //MARK:- Update Video in Casting
    private func updateVideosInCasting() {
        //self.hideViewsAndNotificate(.castingOnly, with: .loadingNextVideo, animated: true)
        if receivedUsersInCasting.count > 0 {
            updateCastingViewFields()
            configureVideoPlayer(with: receivedVideo.url)
        } else {
            WebVideo.getUnwatched { (serverResult) in
                switch serverResult {
                case .error(let error):
                    print("Server error: \(error)")
                    //MARK:- Network Error
                    self.hideViewsAndNotificate(.both, with: .networkError)

                    break
                case .results(let users):
                    //MARK:- Results
                    self.receivedUsersInCasting = users
                    print("Received \(self.receivedUsersInCasting.count) videos to show")

                    if self.receivedUsersInCasting.count > 0 {
                        self.updateCastingViewFields()
                        self.configureVideoPlayer(with: self.receivedVideo.url)

                    } else {
                        //MARK:- No Videos Left
                        self.hideViewsAndNotificate(.both, with: .noVideosLeft)
                    }
                }
            }
        }
    }
    
    
    //MARK:- Update Casting View Fields
    private func updateCastingViewFields() {
        let curUser = self.receivedUsersInCasting.removeLast()
        userId = curUser.id
        self.starNameLabel.text = curUser.name
        self.starDescriptionLabel.text = curUser.description
        self.receivedVideo = curUser.video.translatedToVideoType()
        starImageView.image = UIImage(systemName: "person.crop.circle.fill")
        if let imageName = curUser.profilePhoto {
            self.starImageView.setProfileImage(named: imageName)
        }
        showViews()
    }
    
    
    //MARK:- Configure Views
    private func configureViews() {
        //likeButton.addBlur()
        //dislikeButton.addBlur()
        likeButton.dropButtonShadow()
        dislikeButton.dropButtonShadow()
        superLikeButton.dropButtonShadow()
        replayButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        replayButton.isHidden = true
        muteButton.backgroundColor = replayButton.backgroundColor
        videoGravityButton.backgroundColor = replayButton.backgroundColor
        fullVideoButton.backgroundColor = replayButton.backgroundColor
        
        /*//MARK:- Mute CastingVC at load
        muteButton.isHidden = false
        Globals.isMuted = true*/
        
        castingView.dropShadow()
        starNameLabel.dropShadow(color: .black, opacity: 0.8)
        starDescriptionLabel.dropShadow(color: .black, shadowRadius: 3.0, opacity: 0.9)
        updateControls()
    }
    
    
    //MARK:- Configure Video View
    private func configureVideoView() {
    
        playerVC.view.frame = videoView.bounds
        //fill video content in frame ⬇️
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 25
        //playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        if #available(iOS 13.0, *) {
            playerVC.view.backgroundColor = .quaternarySystemFill
        } else {
            playerVC.view.backgroundColor = .lightGray
        }
        playerVC.showsPlaybackControls = false
        
        //MARK:- insert player into videoView
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.insertSubview(playerVC.view, belowSubview: replayButton)
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
    
   //MARK:- Configure Video Player
    private func configureVideoPlayer(with videoUrl: URL?) {
        removeVideoObserver()
        guard let url = videoUrl else {
            print("invalid url. cannot play video")
            return
        }
        playerVC.player = AVPlayer(url: url)
        //MARK:- Cache Video
        CacheManager.shared.getFileWith(fileUrl: url) { (result) in
            switch result {
            case.failure(let stringError): print(stringError)
            case.success(let cachedUrl):
                self.receivedVideo.url = cachedUrl
            }
        }
        enableLoadingIndicator()

        //MARK: present video from specified point:
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1000))
        playerVC.player?.isMuted = Globals.isMuted
        addVideoObserver()
        replayButton.isHidden = true
        //print(receivedVideo.length)
        playerVC.player?.play()
    }
    
    
    //MARK:- Remove All Video Observers
    private func removeVideoObserver() {
        if let timeObserver = videoTimeObserver {
            //removing time obse
            playerVC.player?.removeTimeObserver(timeObserver)
            videoTimeObserver = nil
        }
        if videoDidEndPlayingObserver != nil {
            NotificationCenter.default.removeObserver(self)
            videoDidEndPlayingObserver = nil
        }
    }
    
    //MARK:- Add All Video Observers
    private func addVideoObserver() {
        removeVideoObserver()
        
        //MARK:- Video Time Observer
        let interval = CMTimeMake(value: 1, timescale: 100)
        videoTimeObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            
            //MARK:- • stop video at specified time.
            // (Can also make progressView for showing as a video progress from here later)
            let currentTime = CMTimeGetSeconds(time)
            //print(currentTime)
            if abs(currentTime - self!.receivedVideo.endTime) <= 0.01 {
                self?.playerVC.player?.pause()
                self?.replayButton.isHidden = false
            } else {
                //self?.disableLoadingIndicator()
                //self?.replayButton.isHidden = true
            }
            
            //MARK:- • enable loading indicator when player is loading
            switch self?.playerVC.player?.currentItem?.status{
            case .readyToPlay:
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
                //break
            case .failed:
                self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                self?.shouldReload = true
                //break
            default:
                //self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                self?.shouldReload = true
                //break
            }
        }
        
        //MARK: Video Did End Playing Observer
        videoDidEndPlayingObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerVC.player?.currentItem)
    }
    
    @objc private func videoDidEnd() {
        replayButton.isHidden = false
    }
        
    
    //MARK:- Custom Image inside NavBar
    private func setupNavBarCustomImageView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        //title = "Large Title"

      // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }

        navigationBar.addSubview(addVideoButtonImageView)

        addVideoButtonImageView.layer.cornerRadius = 16
        addVideoButtonImageView.clipsToBounds = true
        addVideoButtonImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addVideoButtonImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -16),
            addVideoButtonImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -12),
            addVideoButtonImageView.heightAnchor.constraint(equalToConstant: 32),
            addVideoButtonImageView.widthAnchor.constraint(equalTo: addVideoButtonImageView.heightAnchor)
        ])
    }
    
    //MARK:- Setting Up Right Button in NavBar
    //preferred solution with UIButton but with some minuses
    private func setupNavBarRightButton() {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        let rightButton = UIButton()

        rightButton.setBackgroundImage(UIImage(named: "plus128.png"), for: .normal)
        //rightButton.setImage(UIImage(named: "plus32.png"), for: .normal)
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
            attributedText = NSMutableAttributedString(string: "Не удалось связаться с сервером.\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 34.0)])
            attributedText.append(
                NSMutableAttributedString(string: """
            \nПроверьте подключение к интернету и обновите окно.
            """,
                attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0)])
            )
            
            //MARK:- No Videos Left
        case .noVideosLeft:
            attributedText = NSMutableAttributedString(string: "Ого!\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 34.0)])
            attributedText.append(
                NSMutableAttributedString(string: """
            Вы посмотрели все видео в кастинге. Лучшие из них вы можете пересмотреть в разделе "Рейтинг", а ещё можете загрузить своё.
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
        muteButton.isHidden = true
        videoGravityButton.isHidden = true
        fullVideoButton.isHidden = true
    }
    
    //MARK:- Update Contol Buttons Images
    func updateControls() {
        let muteImg = Globals.isMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.2.fill")
        let gravImg = playerVC.videoGravity == .resizeAspectFill ? UIImage(systemName: "rectangle.compress.vertical") : UIImage(systemName: "rectangle.expand.vertical")
        
        videoGravityButton.setImage(gravImg, for: .normal)
        muteButton.setImage(muteImg, for: .normal)
    }
    
}

//MARK:- Tab Bar Controller Delegate
extension CastingViewController: UITabBarControllerDelegate {}
