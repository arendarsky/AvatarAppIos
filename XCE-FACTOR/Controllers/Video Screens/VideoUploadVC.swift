//
//MARK:  VideoUploadVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 21.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Alamofire
import Amplitude

final class VideoUploadVC: XceFactorViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var uploadingVideoNotification: UILabel!
    @IBOutlet private weak var uploadProgressView: UIProgressView!
    @IBOutlet private weak var compressActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var controlsView: UIView!
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var videoRangeSlider: ABVideoRangeSlider!
    
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet var saveAndUploadButton: UIBarButtonItem!
    
    // MARK: - Public Properties

    var video = Video()
    var isProfileInitiated = false
    var isProfileDirectly = false
    var isCastingInitiated = false
    var isEditingVideoInterval = false
    var profileDescription = ""

    // MARK: - Private Properties
    
    private lazy var player = AVPlayer(url: video.url!)
    private var playerVC = AVPlayerViewController()
    private var spinner: UIActivityIndicatorView?
    private var videoObserver: Any?
    private var videoDidEndPlayingObserver: Any?

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private let profileManager = ProfileServicesManager(networkClient: NetworkClient())
    private var alertFactory: AlertFactoryProtocol?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Инициализирвоать в билдере, при переписи на MVP поправить:
        alertFactory = AlertFactory(viewController: self)

        configureCustomNavBar()
        configureVideoRangeSlider()
        configurePlayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        controlsView.isHidden = false
        videoRangeSlider.isHidden = false
        addVideoObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
        controlsView.isHidden = true
        videoRangeSlider.isHidden = true
        playerVC.player?.pause()
        playPauseButton.setImage(IconsManager.getIcon(.play), for: .normal)
        removeVideoObserver()
    }
    
    // MARK: - IBActions

    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if playerVC.player?.timeControlStatus == .playing {
            playerVC.player?.pause()
            playPauseButton.setImage(IconsManager.getIcon(.play), for: .normal)
        } else {
            playerVC.player?.play()
            playPauseButton.setImage(IconsManager.getIcon(.pause), for: .normal)
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        playerVC.player?.pause()
        playPauseButton.setImage(IconsManager.getIcon(.play), for: .normal)
        enableLoadingIndicator()
        //rangeSlider.isEnabled = false
        
        if profileDescription != "" {
            profileManager.set(description: profileDescription) { result in
                switch result {
                case .failure(let error):
                    print("Error setting description: \(error)")
                case .success:
                     print("Success")
                }
            }
        }
        
        //MARK:- Saving Video
        if isEditingVideoInterval {
            setIntervalRequest()
        } else {
            /// Logging New Video Upload
            Amplitude.instance()?.logEvent("newvideo_save_button_tapped")
            uploadingVideoNotification.text = "Подготовка...\n"
            uploadingVideoNotification.setViewWithAnimation(in: view, hidden: false, duration: 0.3) {
                self.compressActivityIndicator.startAnimating()
            }
            /// Compressing
            VideoHelper.encodeVideo(at: video.url!) { compressedUrl, error in
                self.compressActivityIndicator.stopAnimating()
                
                if error != nil {
                    self.alertFactory?.showAlert(type: .handleError)
                    self.disableUploadMode()
                    return
                }
                //MARK:- Uploading
                self.uploadingVideoNotification.text = "Загрузка видео\n"
                self.uploadProgressView.setViewWithAnimation(in: self.view, hidden: false, duration: 0.3)
                self.uploadVideoAndSetInterval(with: compressedUrl)
            }
            
        }
    }

    // MARK: - Actions

    @objc private func videoDidEnd() {
        playPauseButton.setImage(IconsManager.getIcon(.play), for: .normal)
    }
}

// MARK: - Private Methods

private extension VideoUploadVC {

    func configurePlayer(){
        //let player = AVPlayer(url: self.video.URL!)
        //let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.view.frame = videoView.bounds
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 16
        if #available(iOS 13.0, *) {
            playerVC.view.backgroundColor = .quaternarySystemFill
        } else {
            playerVC.view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            playPauseButton.setImage(IconsManager.getIcon(.pause), for: .normal)
            saveAndUploadButton.image = IconsManager.getIcon(.checkmarkSeal)
        }
        
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.insertSubview(playerVC.view, belowSubview: controlsView)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        playerVC.exitsFullScreenWhenPlaybackEnds = false
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
        playerVC.player?.play()
        
        if isEditingVideoInterval {
            playerVC.player?.isMuted = Globals.isMuted
        }
    }
    
    func removeVideoObserver() {
        if let timeObserver = self.videoObserver {
            //removing time obse
            playerVC.player?.removeTimeObserver(timeObserver)
            videoObserver = nil
        }
        if self.videoDidEndPlayingObserver != nil {
            NotificationCenter.default.removeObserver(self)
            videoDidEndPlayingObserver = nil
        }
    }
    
    func addVideoObservers() {
        removeVideoObserver()
        
        /// time observer
        let interval = CMTimeMake(value: 1, timescale: 600)
        videoObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            self?.videoRangeSlider.updateProgressIndicator(seconds: currentTime)
        }
        
        /// Video Did End Playing Observer
        videoDidEndPlayingObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerVC.player?.currentItem)
    }

    func configureVideoRangeSlider() {
        if !isEditingVideoInterval {
            if video.length > 30 {
                video.startTime = video.length / 2 - 15
                video.endTime = video.length / 2 + 15
            }
            else {
                video.startTime = 0
                video.endTime = video.length
            }
        }
        videoRangeSlider.setVideoURL(videoURL: video.url!)
        videoRangeSlider.delegate = self
        videoRangeSlider.minSpace = 3.0
        videoRangeSlider.maxSpace = 30.0
        videoRangeSlider.setStartPosition(seconds: Float(video.startTime))
        videoRangeSlider.setEndPosition(seconds: Float(video.endTime))
        videoRangeSlider.progressPercentage = videoRangeSlider.startPercentage
        videoRangeSlider.isProgressIndicatorSticky = true
        
        videoRangeSlider.startTimeView.setCustomView(backgroundColor: .black, textColor: .white)
        videoRangeSlider.endTimeView.setCustomView(backgroundColor: .black, textColor: .white)
        videoRangeSlider.startTimeView.isHidden = true
        videoRangeSlider.endTimeView.isHidden = true
    }
    
    func enableLoadingIndicator(){
        if spinner == nil {
            spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        }
        let barButton = UIBarButtonItem(customView: spinner!)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        spinner!.startAnimating()
    }
    
    //MARK:- Upload Video Requset
    func uploadVideoAndSetInterval(with url: URL?) {
        WebVideo.uploadVideo(url: url, uploadProgress: { (progressFractionCompleted) in
            self.uploadProgressView.setProgress(progressFractionCompleted, animated: true)
        }) { (serverResult) in
            switch serverResult {
            case.error(let sessionError):
                self.disableUploadMode()
                switch sessionError {
                case .requestTimedOut:
                    self.alertFactory?.showAlert(type: .requestTimedOut)
                default:
                    self.alertFactory?.showAlert(type: .connectionToServerError)
                }
            case.results(let videoNameResult):
                self.updateVideosCount()
                guard let videoName = videoNameResult else {
                    DispatchQueue.main.async {
                        self.exitUploadScreen()
                    }
                    return
                }
                self.video.name = videoName
                print("Response video name: \(self.video.name)")
                print("Now setting start time: \(self.video.startTime) and end time: \(self.video.endTime)")
                self.setIntervalRequest()
            }
        }
    }
    
    //MARK:- Setting Interval Requset
    func setIntervalRequest() {
        WebVideo.setInterval(videoName: self.video.name, startTime: self.video.startTime, endTime: self.video.endTime) { (isSuccess) in
            //if isSuccess {
                self.exitUploadScreen()
            //} else {
                //self.showErrorConnectingToServerAlert(title: "Не удалось обновить фрагмент", message: "Попробуйте еще раз")
            //}
        }
    }

    ///hide upload notifications and enable buttons
    func disableUploadMode() {
        uploadProgressView.isHidden = true
        uploadingVideoNotification.isHidden = true
        disableLoadingIndicator()
        saveAndUploadButton.isEnabled = true
    }

    func exitUploadScreen() {
        disableUploadMode()
        alertFactory?.showAlert(type: isEditingVideoInterval ? .intervalEditing : .uploadingVideo) { _ in
            if self.isCastingInitiated {
                self.dismiss(animated: true, completion: nil)
            } else if self.isProfileDirectly,
                let vc = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 2] as? ProfileViewController {
                vc.shouldUpdateData = true
                self.navigationController?.popToViewController(vc, animated: true)
            } else if self.isProfileInitiated,
                self.navigationController!.viewControllers.count >= 3,
                let vc = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 3] as? ProfileViewController {
                vc.shouldUpdateData = true
                self.navigationController?.popToViewController(vc, animated: true)
            } else {
                //self.navigationController?.popToRootViewController(animated: true)
                self.setApplicationRootVC(storyboardID: "MainTabBarController")
            }
        }
    }
    
    //MARK:- Update Videos Count
    func updateVideosCount() {
        if Globals.user.videosCount == nil {
            Globals.user.videosCount = 1
        } else {
            Globals.user.videosCount! += 1
        }
    }
    
    func disableLoadingIndicator(){
        spinner?.stopAnimating()
        navigationItem.setRightBarButton(saveAndUploadButton, animated: true)
    }
    
    func secondsFromValue(value: CGFloat) -> Float64{
        return videoRangeSlider.duration * Float64(value / 100)
    }
}

// MARK: - Range Slider Delegate

extension VideoUploadVC: ABVideoRangeSliderDelegate {
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        video.startTime = startTime
        video.endTime = endTime
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        playerVC.player?.seek(to: CMTime(seconds: position, preferredTimescale: 600))
    }
    
    func sliderGesturesBegan() {
        let duration = 0.1
        videoRangeSlider.startTimeView.setViewWithAnimation(in: videoView, hidden: false, startDelay: 0.0, duration: duration)
        videoRangeSlider.endTimeView.setViewWithAnimation(in: videoView, hidden: false, startDelay: 0.0, duration: duration)
    }
    
    func sliderGesturesEnded() {
        let duration = 0.1
        videoRangeSlider.startTimeView.setViewWithAnimation(in: videoView, hidden: true, startDelay: 0.0, duration: duration)
        videoRangeSlider.endTimeView.setViewWithAnimation(in: videoView, hidden: true, startDelay: 0.0, duration: duration)
        
        //MARK:- slider's bugs correction
        if video.endTime - video.startTime > 30 {
            if video.endTime == videoRangeSlider.duration {
                videoRangeSlider.setStartPosition(seconds: Float(video.endTime - 30))
                video.startTime = video.endTime - 30
            } else {
                videoRangeSlider.setEndPosition(seconds: Float(video.startTime + 30))
                video.endTime = video.startTime + 30
            }
        }
    }
}

// MARK: - ABTimeView + Extensions

private extension ABTimeView {

    func setCustomView(backgroundColor: UIColor, textColor: UIColor) {
        backgroundView.backgroundColor = backgroundColor
        backgroundView.alpha = 0.5
        backgroundView.layer.cornerRadius = 8.0
        timeLabel.textColor = textColor
        marginLeft = 0.0
        marginRight = 0.0
    }
}
