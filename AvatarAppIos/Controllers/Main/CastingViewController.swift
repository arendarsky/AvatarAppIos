//
//  CastingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 28.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import WebKit
import AVKit
import MobileCoreServices
import NVActivityIndicatorView

class CastingViewController: UIViewController {

    //MARK: Properties declaration
    private var firstLoad = true
    
    private var testURL = "https://devstreaming-cdn.apple.com/videos/app_store/Seriously_Developer_Insight/Seriously_Developer_Insight_hd.mp4"
    private var receivedVideo = Video()
    private var receivedVideoNames = [String]()
    //var serverURL: URL?
    //var player = AVPlayer(url: self.serverURL!)
    private var playerVC = AVPlayerViewController()
    private var loadingIndicator: NVActivityIndicatorView?
    private var imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
    private var videoObserver: Any?
    
    //@IBOutlet weak var videoWebView: WKWebView!
    @IBOutlet weak var castingView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var starName: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var superLikeButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        self.receivedVideo = Video(stringUrl: self.testURL, length: 30, startTime: 0, endTime: 30)
        
        enableLoadingIndicator()
        setupNavBarRightButton()
        
        //MARK:- Fetch Video Names
        WebVideo.getUrls_Admin { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Server error: \(error)")
                break
            case .results(let result):
                self.receivedVideoNames = result
                if self.receivedVideoNames.count > 0 {
                    self.receivedVideo.name = self.receivedVideoNames.removeLast()
                    self.testURL = "\(domain)/api/video/" + self.receivedVideo.name
                    self.receivedVideo.url = URL(string: self.testURL)
                    
                }else{
                    //notificate about empty video list
                }
                print(self.testURL)
                print(self.receivedVideo.url!)
                self.configureVideoView()
                self.configureVideoPlayer(with: self.receivedVideo.url)
            }
        }
        
        castingView.dropShadow()
        configureButtons()

    }
    
    //MARK:- View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            firstLoad = false
        } else {
            replayButton.isHidden = false
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
    
    
    //MARK:- Repeat Video
    @IBAction private func repeatButtonPressed(_ sender: Any) {
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
    
    //MARK:- Dislike Button Actions
    @IBAction private func dislikeButtonPressed(_ sender: Any) {
        replayButton.isHidden = true
        enableLoadingIndicator()
        if receivedVideoNames.count > 0 {
            receivedVideo.name = receivedVideoNames.removeLast()
            testURL = "\(domain)/api/video/\(receivedVideo.name)"
        } else {
            testURL = "https://devstreaming-cdn.apple.com/videos/tutorials/20190910/201gkmn78ytrxz/whats_new_in_sharing/whats_new_in_sharing_hd.mp4"
        }
        
        receivedVideo.url = URL(string: testURL)
        print(receivedVideoNames.count)
        print(receivedVideo.url ?? "some url error")
        enableLoadingIndicator()
        configureVideoPlayer(with: receivedVideo.url)
        //disableLoadingIndicator()
    }
    
    //MARK:- Like Button Actions
    @IBAction private func likeButtonPressed(_ sender: Any) {
        //ternary operator to switch between button colors after pressing it
        //likeButton.tintColor = (likeButton.tintColor == .systemRed ? .label : .systemRed)

        print(receivedVideo.name)

        if receivedVideoNames.count > 0 {
            WebVideo.setLike(videoName: receivedVideo.name)
            receivedVideo.name = receivedVideoNames.removeLast()
            testURL = "\(domain)/api/video/\(receivedVideo.name)"
        } else {
            testURL = "https://devstreaming-cdn.apple.com/videos/tutorials/20190910/201gkmn78ytrxz/whats_new_in_sharing/whats_new_in_sharing_hd.mp4"
        }
        
        receivedVideo.url = URL(string: testURL)
        enableLoadingIndicator()
        configureVideoPlayer(with: receivedVideo.url)
    }
    
    //MARK: Super Like Button Pressed
    @IBAction func superLikeButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show MessageVC", sender: sender)
    }
    
    //MARK:- Add new video button pressed
    @objc private func rightNavBarButtonPressed() {
        print("button tapped")
        performSegue(withIdentifier: "Upload new video", sender: nil)
    }

}


extension CastingViewController {
    //MARK:- Configure Loading Indicator
    private func enableLoadingIndicator() {
        if loadingIndicator == nil {
            
            let width: CGFloat = 40.0
            let frame = CGRect(x: (videoView.center.x - width/2), y: (videoView.center.y - width/2), width: width, height: width)
            
            loadingIndicator = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .white, padding: 8.0)
            loadingIndicator?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loadingIndicator?.layer.cornerRadius = 4

            videoView.addSubview(loadingIndicator!)
        }
        loadingIndicator!.startAnimating()
        loadingIndicator!.isHidden = false
    }
    
    private func disableLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.isHidden = true
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
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 12
        playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        playerVC.view.backgroundColor = .quaternarySystemFill
        playerVC.showsPlaybackControls = false
        
        //MARK:- insert player into videoView
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.insertSubview(playerVC.view, belowSubview: loadingIndicator!)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
        
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
        
        addVideoObserver()
    }
    
    
    //MARK:- Remove Video Time Observer
    private func removeVideoObserver() {
        if let observer = self.videoObserver {
            //removing time obse
            playerVC.player?.removeTimeObserver(observer)
            videoObserver = nil
        }
    }
    
    //MARK:- Add Video Time Observer
    private func addVideoObserver() {
        removeVideoObserver()
        
        //MARK:- Video Observers
        //stop video at specified time. (Can also make progressView from here later)
        let interval = CMTimeMake(value: 1, timescale: 1)
        videoObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            print(currentTime)
            if currentTime >= (self?.receivedVideo.endTime)! {
                self?.playerVC.player?.pause()
                self?.replayButton.isHidden = false
            } else {
                //self?.disableLoadingIndicator()
                self?.replayButton.isHidden = true
            }
            
            switch self?.playerVC.player?.currentItem?.status{
            case .readyToPlay:
                if let _ = self?.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp {
                    self?.disableLoadingIndicator()
                }else {
                    self?.enableLoadingIndicator()
                }
                
                if let _ = self?.playerVC.player?.currentItem?.isPlaybackBufferEmpty {
                    self?.disableLoadingIndicator()
                }else {
                    self?.enableLoadingIndicator()
                }
                break
            case .failed:
                self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                break
            default:
                break
            }
        }
    }
    
    //MARK:- Custom Image inside NavBar
    private func setupNavBarCustomImageView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        //title = "Large Title"

      // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }

        navigationBar.addSubview(imageView)

        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 32),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
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
