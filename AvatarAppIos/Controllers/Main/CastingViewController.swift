//
//  CastingViewController.swift
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

    //MARK: Properties declaration
    private var firstLoad = true
    
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
    
    //@IBOutlet weak var videoWebView: WKWebView!
    @IBOutlet weak var castingView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var starNameLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var starDescriptionLabel: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var superLikeButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    
    ///
//MARK:- CastingVC Lifecycle
    ///
    ///
    
    //MARK:- • View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCustomNavBar()
        
        handlePossibleSoundError()
        enableLoadingIndicator()

        self.receivedVideo = Video(stringUrl: self.testURL, length: 30, startTime: 0, endTime: 30)
        
        //MARK:- Fetch Videos List
        WebVideo.getUnwatched { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Server error: \(error)")
                break
            case .results(let result):
                self.receivedUsersInCasting = result
                print("Received \(self.receivedUsersInCasting.count) videos to show")
                if self.receivedUsersInCasting.count > 0 {
                    self.updateCastingViewFields()
                } else {
                    //notificate about empty video list
                }
                print("test url:", self.testURL)
                print("video url:", self.receivedVideo.url!)
                self.configureVideoPlayer(with: self.receivedVideo.url)
            }
        }
        
        ///custom button for large title in casting view
        //setupNavBarRightButton()
        configureButtons()
        configureVideoView()
        castingView.dropShadow()
        starNameLabel.dropShadow(color: .black, opacity: 0.8)
        starDescriptionLabel.dropShadow(color: .black, shadowRadius: 3.0, opacity: 0.9)
    }
    
    //MARK:- • View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            firstLoad = false
        } else {
            replayButton.isHidden = false
            disableLoadingIndicator()
        }
        //playerVC.player?.play()
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    //MARK:- • Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeVideoObserver()
        playerVC.player?.pause()

    }
    
    //MARK:- • Did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    //MARK:- Replay Button Pressed
    @IBAction private func replayButtonPressed(_ sender: Any) {
        enableLoadingIndicator()
        replayButton.isHidden = true
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 100))
        playerVC.player?.play()
        
        addVideoObserver()
    }

    //MARK:- Show Full Video
    @IBAction private func showFullVideoButtonPressed(_ sender: Any) {
        playerVC.player?.pause()
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 100))
        let fullScreenPlayer = AVPlayer(url: receivedVideo.url!)
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        
        present(fullScreenPlayerVC, animated: true) {
            fullScreenPlayer.play()
        }
    }
    
    //MARK:- Dislike Button Pressed
    @IBAction private func dislikeButtonPressed(_ sender: Any) {
        replayButton.isHidden = true
        enableLoadingIndicator()
        
        WebVideo.setLike(videoName: receivedVideo.name, isLike: false)
        updateVideoInCasting()
        print("Videos left:", receivedUsersInCasting.count)
        print("curr video url:", receivedVideo.url ?? "some url error")

    }
    
    //MARK:- Like Button Pressed
    @IBAction private func likeButtonPressed(_ sender: Any) {
        //ternary operator to switch between button colors after pressing it
        //likeButton.tintColor = (likeButton.tintColor == .systemRed ? .label : .systemRed)
        replayButton.isHidden = true
        enableLoadingIndicator()
        print(receivedVideo.name)

        WebVideo.setLike(videoName: receivedVideo.name)
        updateVideoInCasting()
        print("Videos left:", receivedUsersInCasting.count)
        print("curr video url:", receivedVideo.url ?? "some url error")
        
    }
    
    //MARK: Super Like Button Pressed
    @IBAction func superLikeButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show MessageVC", sender: sender)
    }
    
    @IBAction func addVideoButtonPressed(_ sender: Any) {
        rightNavBarButtonPressed()
    }
    
    
    //MARK:- Add new video button pressed
    @objc private func rightNavBarButtonPressed() {
        print("button tapped")
        playerVC.player?.pause()
        replayButton.isHidden = false
        performSegue(withIdentifier: "Upload new video", sender: nil)
        replayButton.isHidden = false
    }

}

//MARK:- Casting VC Configurations
///
///
extension CastingViewController {
    //MARK:- Configure Loading Indicator
    private func enableLoadingIndicator() {
        if loadingIndicator == nil {
            
            let width: CGFloat = 40.0
            let frame = CGRect(x: (videoView.bounds.midX - width/2), y: (videoView.bounds.midY - width/2), width: width, height: width)
            
            loadingIndicator = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .white, padding: 8.0)
            loadingIndicator?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loadingIndicator?.layer.cornerRadius = 4

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
    
    private func disableLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.isHidden = true
    }
    
   //MARK:- Update Video in Casting
    private func updateVideoInCasting() {
        if receivedUsersInCasting.count > 0 {
            updateCastingViewFields()
            configureVideoPlayer(with: receivedVideo.url)
        } else {
            WebVideo.getUnwatched { (serverResult) in
                switch serverResult {
                case .error(let error):
                    print("Error: \(error)")
                    break
                case .results(let users):
                    self.receivedUsersInCasting += users
                    if self.receivedUsersInCasting.count > 0 {
                        self.updateCastingViewFields()
                        self.configureVideoPlayer(with: self.receivedVideo.url)

                    } else {
                        self.showErrorConnectingToServerAlert(title: "Видео закончились", message: "Сейчас будет дефолтное видео")
                        self.testURL = "https://devstreaming-cdn.apple.com/videos/tutorials/20190910/201gkmn78ytrxz/whats_new_in_sharing/whats_new_in_sharing_hd.mp4"
                        self.configureVideoPlayer(with: URL(string: self.testURL))
                    }
                }
            }
        }
    }
    
    
    //MARK:- Update Casting View Fields
    private func updateCastingViewFields() {
        let curUser = self.receivedUsersInCasting.removeLast()
        self.starNameLabel.text = curUser.name
        self.starDescriptionLabel.text = curUser.description
        self.receivedVideo = curUser.video.translateToVideoType()
        if let imageName = curUser.profilePhoto {
            self.starImageView.setProfileImage(named: imageName)
        }
    }
    
    
    //MARK:- Configure Button Views
    private func configureButtons() {
        //likeButton.addBlur()
        //dislikeButton.addBlur()
        likeButton.dropButtonShadow()
        dislikeButton.dropButtonShadow()
        superLikeButton.dropButtonShadow()
        replayButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        replayButton.isHidden = true
    }
    
    
    //MARK:- Configure Video View
    private func configureVideoView() {
    
        playerVC.view.frame = videoView.bounds
        //fill video content in frame ⬇️
        //playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 25
        //playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        playerVC.view.backgroundColor = .quaternarySystemFill
        playerVC.showsPlaybackControls = false
        
        //MARK:- insert player into videoView
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.insertSubview(playerVC.view, belowSubview: loadingIndicator!)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
        
        //MARK:- One-Tap Gesture Recognizer for Video View
        videoView.addTapGestureRecognizer {
            if self.replayButton.isHidden {
                self.replayButton.setViewWithAnimation(in: self.videoView, hidden: false, duration: 0.2)
            } else {
                self.replayButton.setViewWithAnimation(in: self.videoView, hidden: true, duration: 0.2)
            }
        }
    }
    
   //MARK:- Configure Video Player
    private func configureVideoPlayer(with url: URL?) {
        removeVideoObserver()
        
        if url != nil {
            playerVC.player = AVPlayer(url: url!)
        } else {
            print("invalid url. cannot play video")
            return
        }

        //MARK: present video from specified point:
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 600))
        playerVC.player?.play()
        //print(receivedVideo.length)
        addVideoObserver()
    }
    
    
    //MARK:- Remove All Video Observers
    private func removeVideoObserver() {
        if let timeObserver = self.videoTimeObserver {
            //removing time obse
            playerVC.player?.removeTimeObserver(timeObserver)
            videoTimeObserver = nil
        }
        if self.videoDidEndPlayingObserver != nil {
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
                if (self?.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp)! {
                    self?.disableLoadingIndicator()
                } else {
                    self?.enableLoadingIndicator()
                }
                
                if (self?.playerVC.player?.currentItem?.isPlaybackBufferEmpty)! {
                    self?.enableLoadingIndicator()
                }else {
                    self?.disableLoadingIndicator()
                }
                break
            case .failed:
                self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                break
            default:
                break
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
    
}
