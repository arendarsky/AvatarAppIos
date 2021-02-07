//
//MARK:  RatingCell.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import NVActivityIndicatorView

@objc protocol RatingCellDelegate: class {
    func ratingCellDidPressPlayButton(_ sender: RatingCell)
    
    func ratingCellDidPressMuteButton(_ sender: RatingCell)
    
    func handleTapOnRatingCell(_ sender: RatingCell)
    
    func ratingcellDidPressMenu(_ sender: RatingCell)
    
    @objc optional func ratingCellFailedToLoadVideo(_ sender: RatingCell)
    
    @objc optional func ratingCell(didLoadVideoAt index: Int, _ asset: AVAsset, with startTime: Double)
}

final class RatingCell: UICollectionViewCell {

    weak var delegate: RatingCellDelegate?
    
    var index: Int = 0
    var playerVC = AVPlayerViewController()
    var video = Video()
    var gravityMode = AVLayerVideoGravity.resizeAspectFill
    var shouldReplay = false
    var shouldReload = false
    var profileImageName: String?
    var videoTimeObserver: Any?
    var videoDidEndPlayingObserver: Any?
    var videoPlaybackErrorObserver: Any?
    var volumeObserver: Any?
    var loadingIndicator: NVActivityIndicatorView?

    // MARK: - IBOutlets
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var ratingVideoMenuButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var videoGravityButton: UIButton!
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        addVideoViewTapGestureRecognizers()
        addTapRecognizersToName()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        removeVideoObserverSafe()
    }
    
    // MARK: - IBActions

    @IBAction func ratingCellMenuPressed(_ sender: Any) {
        delegate?.ratingcellDidPressMenu(self)
    }

    @IBAction func gravityButtonPressed(_ sender: UIButton) {
        playerVC.videoGravity = playerVC.videoGravity == AVLayerVideoGravity.resizeAspect ? .resizeAspectFill : .resizeAspect
        updateControls()
    }

    @IBAction func muteButtonPressed(_ sender: UIButton) {
        Globals.isMuted = !Globals.isMuted
        playerVC.player?.isMuted = Globals.isMuted
        updateControls()
        delegate?.ratingCellDidPressMuteButton(self)
    }

    @IBAction func replayButtonPressed(_ sender: Any) {
        replayButton.isHidden = true
        enableLoadingIndicator()
        hideAllControls()
        if let url = video.url { playerVC.player = AVPlayer(url: url) }
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
        playerVC.player?.isMuted = Globals.isMuted
        addVideoObserver()
        playerVC.player?.play()
    }

    @IBAction func playPauseButtonPressed(_ sender: Any) {
        delegate?.ratingCellDidPressPlayButton(self)
        updateControls()
        enableLoadingIndicator()
        if playerVC.player?.timeControlStatus == .playing {
            playerVC.player?.pause()
            playPauseButton.setImage(IconsManager.getIcon(.play), for: .normal)
            //playPauseButton.setButtonWithAnimation(in: videoView, hidden: true, startDelay: 2.0, duration: 0.2)
        } else {
            playVideo()
        }
    }

    // MARK: - Actions

    @objc private func handleOneTapGesture(sender: UITapGestureRecognizer) {
        updatePlayPauseButtonImage()
        updateControls()
        //if replayButton.isHidden {
            playPauseButton.setViewWithAnimation(in: videoView, hidden: !playPauseButton.isHidden, duration: 0.2)
        //}
        muteButton.setViewWithAnimation(in: videoView, hidden: !playPauseButton.isHidden, duration: 0.2)
        //videoGravityButton.setViewWithAnimation(in: videoView, hidden: !playPauseButton.isHidden, duration: 0.2)
    }
    
    @objc func handleDoubleTapGesture() {
        playerVC.videoGravity = playerVC.videoGravity == AVLayerVideoGravity.resizeAspect ? .resizeAspectFill : .resizeAspect
        updateControls()
    }
    
    ///pause cell video player and update its buttons
    func pauseVideo() {
        removeVideoObserverSafe()
        playerVC.player?.pause()
        updateControls()
        //playPauseButton.isHidden = !replayButton.isHidden
        playPauseButton.isHidden = false
        videoGravityButton.isHidden = true
        replayButton.isHidden = true
        muteButton.isHidden = !Globals.isMuted
        loadingIndicator?.stopAnimating()
    }

    func playVideo() {
        if playerVC.player?.timeControlStatus == .playing { return }
        
        playPauseButton.setImage(IconsManager.getIcon(.pause), for: .normal)
        playerVC.player?.isMuted = Globals.isMuted
        
        if shouldReload {
            shouldReload = false
            if let url = video.url {
                playerVC.player = AVPlayer(url: url)
                playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
            }
        } else {
            if let now = playerVC.player?.currentItem?.currentTime().seconds, now >= video.endTime {
                playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
            }
        }
        
        addVideoObserver()
        playerVC.player?.play()
        if !playPauseButton.isHidden {
            playPauseButton.setViewWithAnimation(in: videoView, hidden: true, startDelay: 0.3, duration: 0.2)
        }
    }

    func addVideoViewTapGestureRecognizers() {
        videoView.isUserInteractionEnabled = true
        let oneTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOneTapGesture))
        oneTapRecognizer.numberOfTapsRequired = 1
        videoView.addGestureRecognizer(oneTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture))
        doubleTapRecognizer.numberOfTapsRequired = 2
        videoView.addGestureRecognizer(doubleTapRecognizer)
        oneTapRecognizer.require(toFail: doubleTapRecognizer)
    }

    func addTapRecognizersToName() {
        nameLabel.addTapGestureRecognizer {
            self.delegate?.handleTapOnRatingCell(self)
        }
        profileImageView.addTapGestureRecognizer {
            self.delegate?.handleTapOnRatingCell(self)
        }
        descriptionLabel.addTapGestureRecognizer {
            self.delegate?.handleTapOnRatingCell(self)
        }
    }
}

extension RatingCell {
    
    func configureCell() {
        let cornerRadius: CGFloat = 25
        let maskedCorners: CACornerMask = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        profileImageView.layer.cornerRadius = 15

        videoView.layer.cornerRadius = cornerRadius
        videoView.layer.maskedCorners = maskedCorners
        previewImageView.layer.cornerRadius = cornerRadius
        previewImageView.layer.maskedCorners = maskedCorners

        descriptionView.layer.cornerRadius = cornerRadius
        //descriptionView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        let sRadius: CGFloat = 9.0
        let opacity: Float = 0.7
        ratingVideoMenuButton.dropShadow(color: .black, opacity: opacity)
        profileImageView.dropShadow(color: .black, shadowRadius: sRadius, opacity: opacity, isMaskedToBounds: true)
        positionLabel.dropShadow(color: .black, shadowRadius: sRadius, opacity: opacity)
        likesLabel.dropShadow(color: .black, shadowRadius: sRadius, opacity: opacity)
        nameLabel.dropShadow(color: .black, shadowRadius: sRadius, opacity: opacity)
        descriptionLabel.dropShadow(color: .black, shadowRadius: sRadius, opacity: opacity)
        //with compositional layout, shadow doesn't work correctly.
        //if needed, it may be done using smth like 'SectionBackgroundDecorationView'
        //descriptionView.dropShadow()
        //instead using colored border now:
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor

        playPauseButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //replayButton.backgroundColor = playPauseButton.backgroundColor
        muteButton.backgroundColor = playPauseButton.backgroundColor
        videoGravityButton.backgroundColor = playPauseButton.backgroundColor
        playerVC.videoGravity = gravityMode
        updateControls()

    }

    func configureVideoView(_ parentVC: UIViewController) {
        playerVC.view.frame = videoView.bounds
        //fill video content in frame ⬇️
        playerVC.videoGravity = .resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 25
        //self.playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        if #available(iOS 13.0, *) {
            playerVC.view.backgroundColor = videoView.backgroundColor
        } else {
            let playerColor = UIColor.darkGray.withAlphaComponent(0.5)
            playerVC.view.backgroundColor = playerColor
            videoView.backgroundColor = playerColor
            replayButton.setImage(IconsManager.getIcon(.repeatActionSmall), for: .normal)
        }

        // insert player into videoView
        parentVC.addChild(playerVC)
        playerVC.didMove(toParent: parentVC)
        videoView.insertSubview(playerVC.view, belowSubview: positionLabel)
        videoView.backgroundColor = .clear
        
        playerVC.entersFullScreenWhenPlaybackBegins = false
        playerVC.showsPlaybackControls = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
    }

    func configureVideoPlayer(user: RatingProfile, cachedUrl: URL? = nil) {
        removeVideoObserverSafe()
        print("User's '\(user.name)' video:")
        print(user.video!)
        //let video = findUsersActiveVideo(user)
        video = user.video!.translatedToVideoType()
        guard let videoUrl = video.url else {
            print("invalid url. cannot play video")
            return
        }
        if let url = cachedUrl {
            playerVC.player = AVPlayer(url: url)
        } else {
            playerVC.player = AVPlayer(url: videoUrl)
        }
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
    }

    func configureVideoPlayer(with url: URL?) {
        removeVideoObserverSafe()
        guard let videoUrl = url else {
            print("invalid url. cannot play video")
            return
        }
        video.url = videoUrl
        playerVC.player = AVPlayer(url: videoUrl)
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
    }
    
    //MARK:- Remove All Video Observers
    private func removeVideoObserver() throws {
        if let timeObserver = self.videoTimeObserver {
            //removing time observer
            playerVC.player?.removeTimeObserver(timeObserver)
            videoTimeObserver = nil
        }
        /*if self.videoDidEndPlayingObserver != nil || volumeObserver != nil {
            NotificationCenter.default.removeObserver(self)
            videoDidEndPlayingObserver = nil
            volumeObserver = nil
            videoPlaybackErrorObserver = nil
        }*/
    }

    func removeVideoObserverSafe() {
        do {
            try removeVideoObserver()
        } catch {
            print("Failed to remove observer. Assigning nil")
            videoTimeObserver = nil
        }
    }

    func addVideoObserver() {
        removeVideoObserverSafe()
        
        var timeAfterPlayButtonBecameVisible = 0
        //MARK:- Video Time Observer
        let interval = CMTimeMake(value: 1, timescale: 100)
        videoTimeObserver = playerVC.player?.addPeriodicTimeObserver(forInterval: interval,
                                                                     queue: .main) { [weak self] time in
            timeAfterPlayButtonBecameVisible = timeAfterPlayButtonBecameVisible.countDeadline(
                deadline: 150, condition: self!.playPauseButton.isHidden, handler: {
                self!.playPauseButton.setViewWithAnimation(in: self!.videoView, hidden: true, duration: 0.2)
            })
            
            // Stop video at specified time.
            // (Can also make progressView for showing as a video progress from here later)
            let currentTime = CMTimeGetSeconds(time)
            //print(currentTime)
            if abs(currentTime - self!.video.endTime) <= 0.01 {
                self?.playerVC.player?.pause()
                self?.playerVC.player?.seek(to: CMTime(seconds: self!.video.startTime, preferredTimescale: 1000))
                //self?.replayButton.isHidden = false
                self?.playPauseButton.isHidden = false
                self?.updatePlayPauseButtonImage()
                self?.shouldReplay = true
            } else {
                //self?.disableLoadingIndicator()
                //self?.replayButton.isHidden = currentTime < self!.video.endTime
            }
            
            // Enable loading indicator when player is loading
            if (self?.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp)! {
                self?.disableLoadingIndicator()
            } else {
               self?.enableLoadingIndicator()
                //self?.previewImageView.isHidden = false
            }
            
            if (self?.playerVC.player?.currentItem?.isPlaybackBufferEmpty)! {
                self?.enableLoadingIndicator()
            }else {
                self?.disableLoadingIndicator()
                //self?.previewImageView.isHidden = true
            }
            
            switch self?.playerVC.player?.currentItem?.status{
            case .failed:
                //self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                //self?.replayButton.isHidden = false
                print("\n\n\n>>>> FAILED TO LOAD")
                self?.delegate?.ratingCellFailedToLoadVideo?(self!)
            default:
                break
            }
        }
        
        // Notification Center Observers
        videoDidEndPlayingObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerVC.player?.currentItem)
        
        if videoPlaybackErrorObserver == nil {
            videoPlaybackErrorObserver = NotificationCenter.default.addObserver(self, selector: #selector(videoError), name: .AVPlayerItemNewErrorLogEntry, object: self.playerVC.player?.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(videoError), name: .AVPlayerItemFailedToPlayToEndTime, object: self.playerVC.player?.currentItem)
        }
        
        volumeObserver = NotificationCenter.default.addObserver(self, selector: #selector(volumeDidChange(_:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }

    // MARK: - Actions

    @objc private func videoDidEnd() {
        //replayButton.isHidden = false
        playPauseButton.isHidden = false
        playPauseButton.setImage(IconsManager.getIcon(.play), for: .normal)
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
        shouldReplay = true
    }

    @objc private func videoError() {
        delegate?.ratingCellFailedToLoadVideo?(self)
        playPauseButton.isHidden = false
    }

    @objc func volumeDidChange(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let reason = info["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String,
                  reason == "ExplicitVolumeChange" else { return }

        Globals.isMuted = false
        playerVC.player?.isMuted = Globals.isMuted
        muteButton.setViewWithAnimation(in: self.videoView, hidden: true, duration: 0.3)
        updateControls()
        delegate?.ratingCellDidPressMuteButton(self)
    }

    func enableLoadingIndicator() {
        if loadingIndicator == nil {
            let width: CGFloat = 50.0
            let frame = CGRect(x: (videoView.bounds.midX - width/2), y: (videoView.bounds.midY - width/2), width: width, height: width)
            
            loadingIndicator = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .white, padding: 4.0)
            loadingIndicator!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loadingIndicator!.layer.cornerRadius = width / 2

            videoView.insertSubview(loadingIndicator!, belowSubview: playPauseButton)
            
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

    func disableLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.isHidden = true
    }

    func updatePlayPauseButtonImage() {
        playPauseButton.setImage(IconsManager.getIcon(
            self.playerVC.player?.timeControlStatus == .playing ? .pause : .play), for: .normal)

    }
    
    /// Update Contol Buttons Images
    func updateControls() {
        //playerVC.videoGravity = gravityMode
        let muteImg = Globals.isMuted ? IconsManager.getIcon(.mute) : IconsManager.getIcon(.sound)
        let gravImg = playerVC.videoGravity == .resizeAspectFill ? IconsManager.getIcon(.rectangleCompressVertical) : IconsManager.getIcon(.rectangleExpandVertical)
        
        videoGravityButton.setImage(gravImg, for: .normal)
        muteButton.setImage(muteImg, for: .normal)
        updatePlayPauseButtonImage()
    }

    func hideAllControls() {
        //replayButton.isHidden = true
        playPauseButton.isHidden = true
        muteButton.isHidden = true
        videoGravityButton.isHidden = true
    }

    func prepareForReload() {
        removeVideoObserverSafe()
        shouldReload = true
    }
}
