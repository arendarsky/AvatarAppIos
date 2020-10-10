//
//  VideoPlayerView.swift
//  VideoPlayerView
//
//  Created by Владислав on 04.10.2020.
//

import UIKit
import AVKit
import NVActivityIndicatorView

//MARK:- Delegate Protocol
protocol VideoPlayerViewDelegate: class {
    func didReceivePlaybackError(in videoView: VideoPlayerView)
    
    func didPlayToEnd(in videoView: VideoPlayerView)
    
    func videoView(_ videoView: VideoPlayerView, didChangeMutedStateTo isMuted: Bool)
}

class VideoPlayerView: UIView {
    static let nibName = "VideoPlayerView"
    
    //MARK:- Outlets
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private weak var controlsView: UIView!
    @IBOutlet private weak var muteButton: UIButton!
    @IBOutlet private weak var videoGravityButton: UIButton!
    @IBOutlet private weak var fullScreenButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    
    private var timer: Timer?
    
    private var playerVC = AVPlayerViewController()
    private var video = Video()
    
    private var loadingIndicator: NVActivityIndicatorView?
    private var videoTimeObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    private var volumeObserver: Any?
    private var videoPlaybackErrorObserver: Any?
    
    
    //MARK:- Public
    weak var parent: UIViewController?
    
    weak var delegate: VideoPlayerViewDelegate?
    
    var isMuteButtonEnabled: Bool = true {
        didSet { updateControlsVisibility() }
    }
    
    
    var isFullScreenButtonEnabled: Bool = true {
        didSet { updateControlsVisibility() }
    }
    
    var isVideoGravityButtonEnabled: Bool = false {
        didSet { updateControlsVisibility() }
    }
    
    var isPlaying: Bool {
        return playerVC.player?.timeControlStatus == .playing
    }
    
    
    //MARK:- Play
    public func play() {
        if let now = playerVC.player?.currentItem?.currentTime().seconds, now >= video.endTime {
            playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
        }
        playerVC.player?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        setHideTimer()
    }
    
    //MARK:- Pause
    public func pause() {
        playerVC.player?.pause()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        showControls()
        timer?.invalidate()
    }
    
    //MARK:- Set Muted
    public func setMuted(_ isMuted: Bool) {
        playerVC.player?.isMuted = isMuted
        updateMuteButtonImage()
    }
    
    
    //MARK:- Hide All Controls
    public func hideAllControls(animated: Bool = true) {
        UIView.transition(with: self, duration: animated ? 0.2 : 0.0, options: .transitionCrossDissolve, animations: {
//            self.playPauseButton.isHidden = true
//            self.videoGravityButton.isHidden = true
//            self.fullScreenButton.isHidden = true
//            self.muteButton.isHidden = true
            self.controlsView.isHidden = true
        }, completion: nil)
    }
    
    //MARK:- Show Controls
    ///not all actually
    public func showControls() {
        controlsView.isHidden = false
        //replayButton.isHidden = false
//        muteButton.isHidden = false
//        fullScreenButton.isHidden = false
//        playPauseButton.isHidden = false
        //videoGravityButton.isHidden = false
    }
    
    //MARK:- Configure With URL
    public func configureVideoPlayer(with url: URL?) {
        guard let url = url else {
             print("invalid url. cannot play video")
             return
         }
        let video = Video(stringUrl: url.absoluteString, length: 1e9, startTime: 0, endTime: 1e9)
        configureVideoPlayer(with: video)
    }
    
     public func configureVideoPlayer(with video: Video) {
        guard let url = video.url else {
             print("invalid url. cannot play video")
             return
         }
        self.video = video
        
         removeAllObservers()
 //        //MARK:- • Load local video if exists
 //        if let cachedUrl = CacheManager.shared.getLocalIfExists(at: url) {
 //            playerVC.player = AVPlayer(url: cachedUrl)
 //            receivedVideo.url = cachedUrl
 //            //self.cachedUrl = cachedUrl
 //        } else {
 //            playerVC.player = AVPlayer(url: url)
 //            //cacheVideo(with: url)
 //        }
         playerVC.player = AVPlayer(url: url)
         //MARK: • present video from specified point:
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
         //playerVC.player?.isMuted = Globals.isMuted
         addAllObservers()
         play()
         enableLoadingIndicator()
     }
    
    //MARK:- Configure Video View
    public func configureVideoView(with parent: UIViewController) {
        self.parent = parent
        
        playerVC.view.frame = self.bounds
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = self.layer.cornerRadius
        //playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        playerVC.view.backgroundColor = self.backgroundColor
        playerVC.showsPlaybackControls = false
        playerVC.entersFullScreenWhenPlaybackBegins = false

        //MARK:- insert player into videoView
        parent.addChild(playerVC)
        playerVC.didMove(toParent: parent)
        contentView.insertSubview(playerVC.view, at: 0)
        //playerView.addSubview(playerVC.view)
        self.backgroundColor = .clear

        //MARK:- One-Tap Gesture Recognizer for Video View
        let oneTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOneTap))
        oneTapRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(oneTapRecognizer)
        let doubleTapRecongnizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapRecongnizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapRecongnizer)
        oneTapRecognizer.require(toFail: doubleTapRecongnizer)
        
        self.bringSubviewToFront(controlsView)
    }
    
    
    
    ///
    //MARK:- Private
    ///
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    
    //MARK:- Video Gravity Button Pressed
    @IBAction private func gravityButtonPressed(_ sender: UIButton) {
        if playerVC.videoGravity == .resizeAspectFill {
            playerVC.videoGravity = .resizeAspect
          //  videoGravityButton.setImage(UIImage(systemName: "rectangle.expand.vertical"), for: .normal)
        } else {
            playerVC.videoGravity = .resizeAspectFill
           // videoGravityButton.setImage(UIImage(systemName: "rectangle.compress.vertical"), for: .normal)
        }
        updateGravityButtonImage()
        
    }
    
    //MARK:- Mute Video Button Pressed
    @IBAction private func muteButtonPressed(_ sender: UIButton) {
        playerVC.player?.isMuted.toggle()
        updateMuteButtonImage()
        delegate?.videoView(self, didChangeMutedStateTo: playerVC.player?.isMuted ?? true)
        //Globals.isMuted = !Globals.isMuted
    }
    
    //MARK:- Full Video Button Pressed
    @IBAction private func fullVideoButtonPressed(_ sender: Any) {
        let timeToStart = playerVC.player?.currentTime().seconds ?? video.startTime
        playerVC.player?.pause()
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
        
        showFullScreenPlayer(startTime: timeToStart)
    }
    
    //MARK:- Show FS Player
    private func showFullScreenPlayer(isMuted: Bool = false, startTime: Double) {
        var player: AVPlayer
        if let asset = playerVC.player?.currentItem?.asset {
            let item = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: item)
        } else if let url = video.url {
            player = AVPlayer(url: url)
        } else {
            return
        }
        let fullScreenPlayer = player
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        fullScreenPlayerVC.player?.isMuted = isMuted
        fullScreenPlayerVC.player?.seek(to: CMTime(seconds: startTime, preferredTimescale: 1000))
        setCategoryPlayback()
        parent?.present(fullScreenPlayerVC, animated: true) {
            fullScreenPlayer.play()
        }
    }
    
    //MARK:- DoubleTap on VideoView
    @objc
    private func handleDoubleTap() {
        playerVC.videoGravity = playerVC.videoGravity == .resizeAspect ? .resizeAspectFill : .resizeAspect
        updateGravityButtonImage()
    }
    
    //MARK:- Single Tap on VideoView
    @objc
    private func handleOneTap() {
        let shouldHide = !controlsView.isHidden
        updateGravityButtonImage()
        updateMuteButtonImage()
        
        if shouldHide {
            timer?.invalidate()
        }
        
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.controlsView.isHidden = shouldHide
        }, completion: { _ in
            if !self.controlsView.isHidden && self.isPlaying {
                self.setHideTimer()
            }
        })
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
        
        //MARK:- Video Periodic Time Observer
        let interval = CMTimeMake(value: 1, timescale: 100)
        videoTimeObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            //MARK:- • manage current video time.
            // (Can also make progressView for showing as a video progress from here later)
            let currentTime = CMTimeGetSeconds(time)
            //self?.receivedVideo.currentTime = currentTime
            //print(currentTime)
            let endTime = self.video.endTime// ?? 0
            if abs(currentTime - endTime) <= 0.01 {
                //self?.replayAction()
                //self.playerVC.player?.pause()
                self.showControls()
                self.pause()
            } else {
                if currentTime >= endTime {
                    //self?.replayAction()
                    self.showControls()
                    self.pause()
                }
                //self?.disableLoadingIndicator()
                //self?.replayButton.isHidden = true
            }
            
            //MARK:- • enable loading indicator when player is loading
            //self.shouldReload = false
            if (self.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp)! {
                self.loadingIndicator?.stopAnimating()
            } else {
                self.enableLoadingIndicator()
            }

            if (self.playerVC.player?.currentItem?.isPlaybackBufferEmpty)! {
                self.enableLoadingIndicator()
            }else {
                self.loadingIndicator?.stopAnimating()
            }
            
            switch self.playerVC.player?.currentItem?.status{
            case .failed:
                self.delegate?.didReceivePlaybackError(in: self)
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
        timer?.invalidate()
        showControls()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        //updatePlayPauseButtonImage()
        delegate?.didPlayToEnd(in: self)
    }
    
    //MARK:- Video Playback Error
    @objc private func videoError() {
        delegate?.didReceivePlaybackError(in: self)
        //replayButton.isHidden = false
       // shouldReload = true
    }
    
    //MARK:- Volume Did Change
    @objc func volumeDidChange(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let reason = info["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String,
              reason == "ExplicitVolumeChange"
        else { return }

        playerVC.player?.isMuted = false
        updateMuteButtonImage()
        delegate?.videoView(self, didChangeMutedStateTo: false)
    }
    
    //MARK:- Enable Loading Indictator
    func enableLoadingIndicator() {
        if loadingIndicator == nil {
            let width: CGFloat = 50.0
            let frame = CGRect(x: (self.bounds.midX - width/2), y: (self.bounds.midY - width/2), width: width, height: width)
            
            loadingIndicator = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .white, padding: 4.0)
            loadingIndicator!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loadingIndicator!.layer.cornerRadius = width / 2
            
            self.insertSubview(loadingIndicator!, aboveSubview: controlsView)
            
            //MARK:- constraints: center spinner vertically and horizontally in video view
            loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loadingIndicator!.heightAnchor.constraint(equalToConstant: loadingIndicator!.frame.height),
                loadingIndicator!.widthAnchor.constraint(equalToConstant: loadingIndicator!.frame.width),
                loadingIndicator!.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                loadingIndicator!.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
        }
        loadingIndicator!.startAnimating()
        loadingIndicator!.isHidden = false
    }
    
    //MARK:- Disable Loading Indicator
    func disableLoadingIndicator() {
        loadingIndicator?.stopAnimating()
    }
    
    private func setCategoryPlayback() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
    }
    
    //MARK:- Hide Timer
    ///Hides controls after given time
    private func setHideTimer(repeated: Bool = false) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: repeated) { [weak self] (timer) in
            guard let self = self else { return }
            self.hideAllControls(animated: true)
        }
    }
    
    private func updateMuteButtonImage() {
        let muteImg = (playerVC.player?.isMuted ?? true) ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.2.fill")
        muteButton.setImage(muteImg, for: .normal)
    }
    
    private func updateGravityButtonImage() {
        let gravImg = playerVC.videoGravity == .resizeAspectFill ? UIImage(systemName: "rectangle.compress.vertical") : UIImage(systemName: "rectangle.expand.vertical")
        videoGravityButton.setImage(gravImg, for: .normal)
    }
    
    private func updatePlayPauseButtonImage() {
        let imgName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imgName), for: .normal)
    }
    
    private func updateControlsVisibility() {
        muteButton.isEnabled = isMuteButtonEnabled
        muteButton.isHidden = !isMuteButtonEnabled
        fullScreenButton.isEnabled = isFullScreenButtonEnabled
        fullScreenButton.isHidden = !isFullScreenButtonEnabled
        videoGravityButton.isEnabled = isVideoGravityButtonEnabled
        videoGravityButton.isHidden = !isVideoGravityButtonEnabled
    }
    
    //MARK:- Awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        configureButtons()
        
    }
    
    private func configureButtons() {
        playPauseButton.layer.cornerRadius = playPauseButton.bounds.height / 2
        let cRaduis: CGFloat = 8
        videoGravityButton.layer.cornerRadius = cRaduis
        muteButton.layer.cornerRadius = cRaduis
        fullScreenButton.layer.cornerRadius = cRaduis
        updateControlsVisibility()
    }
    
    
    //MARK:- Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetup()
    }
    
    private func xibSetup() {
        Bundle.main.loadNibNamed(VideoPlayerView.nibName, owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}
