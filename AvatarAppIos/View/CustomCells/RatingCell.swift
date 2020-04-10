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

protocol RatingCellDelegate: class {
    func ratingCellDidPressPlayButton(_ sender: RatingCell)
}

class RatingCell: UICollectionViewCell {
    //MARK:- Properties
    weak var delegate: RatingCellDelegate?
    
    var playerVC = AVPlayerViewController()
    var video = Video()
    var gravityMode = AVLayerVideoGravity.resizeAspectFill
    var shouldReplay = false
    var shouldReload = false
    var profileImageName: String?
    var videoPreviewImage: UIImage?
    var videoTimeObserver: Any?
    var videoDidEndPlayingObserver: Any?
    var loadingIndicator: NVActivityIndicatorView?
    
    @IBOutlet weak var videoView: UIView!
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


    //MARK:- Awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        addTapGestureRecognizers()
    }
    
    //MARK:- Video Gravity Button Pressed
    @IBAction func gravityButtonPressed(_ sender: UIButton) {
        playerVC.videoGravity = playerVC.videoGravity == AVLayerVideoGravity.resizeAspect ? .resizeAspectFill : .resizeAspect
        updateControls()
    }
    
    //MARK:- Mute Video Button Pressed
    @IBAction func muteButtonPressed(_ sender: UIButton) {
        if Globals.isMuted {
            Globals.isMuted = false
            muteButton.setImage(UIImage(systemName: "speaker.2.fill"), for: .normal)
        } else {
            Globals.isMuted = true
            muteButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        }
        playerVC.player?.isMuted = Globals.isMuted
    }
    
    //MARK:- Replay Button Pressed
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
    
    //MARK:- Play/Pause Button Pressed
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        delegate?.ratingCellDidPressPlayButton(self)
        //replayButton.isHidden = false
        enableLoadingIndicator()
        if playerVC.player?.timeControlStatus == .playing {
            playerVC.player?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            //playPauseButton.setButtonWithAnimation(in: videoView, hidden: true, startDelay: 2.0, duration: 0.2)
        } else {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playerVC.player?.isMuted = Globals.isMuted
            if let now = playerVC.player?.currentItem?.currentTime().seconds, now >= video.endTime {
                playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
            }
            addVideoObserver()
            playerVC.player?.play()
            playPauseButton.setButtonWithAnimation(in: videoView, hidden: true, startDelay: 0.3, duration: 0.2)
        }
    }
    
    
    //MARK:- Handle One-Tap Gesture
    @objc private func handleOneTapGesture(sender: UITapGestureRecognizer) {
        updatePlayPauseButtonImage()
        updateControls()
        //if replayButton.isHidden {
            playPauseButton.setButtonWithAnimation(in: videoView, hidden: !playPauseButton.isHidden, duration: 0.2)
        //}
        muteButton.setViewWithAnimation(in: videoView, hidden: !playPauseButton.isHidden, duration: 0.2)
        //videoGravityButton.setViewWithAnimation(in: videoView, hidden: !playPauseButton.isHidden, duration: 0.2)
    }
    
    //MARK:- Handle Double Tap
    @objc func handleDoubleTapGesture() {
        playerVC.videoGravity = playerVC.videoGravity == AVLayerVideoGravity.resizeAspect ? .resizeAspectFill : .resizeAspect
        updateControls()
    }
    
    //MARK:- Pause Video
    ///pause cell video player and update its buttons
    func pauseVideo() {
        playerVC.player?.pause()
        updateControls()
        //playPauseButton.isHidden = !replayButton.isHidden
        playPauseButton.isHidden = false
        muteButton.isHidden = true
        videoGravityButton.isHidden = true
        replayButton.isHidden = true
        loadingIndicator?.stopAnimating()
    }
    
    //MARK:- Add One-Tap Gesture Recognizer
    func addTapGestureRecognizers() {
        videoView.isUserInteractionEnabled = true
        let oneTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOneTapGesture))
        oneTapRecognizer.numberOfTapsRequired = 1
        videoView.addGestureRecognizer(oneTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture))
        doubleTapRecognizer.numberOfTapsRequired = 2
        videoView.addGestureRecognizer(doubleTapRecognizer)
        oneTapRecognizer.require(toFail: doubleTapRecognizer)
    }
    
}

///
//MARK:- Rating Cell Extensions
///
extension RatingCell {
    
    //MARK:- Configure Cell
    func configureCell() {
        profileImageView.layer.cornerRadius = 15

        videoView.layer.cornerRadius = 25
        videoView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        descriptionView.layer.cornerRadius = 25
        //descriptionView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        descriptionView.dropShadow()
        
        playPauseButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //replayButton.backgroundColor = playPauseButton.backgroundColor
        muteButton.backgroundColor = playPauseButton.backgroundColor
        videoGravityButton.backgroundColor = playPauseButton.backgroundColor
        playerVC.videoGravity = gravityMode
        updateControls()
        
        /* does not work correct
        likesLabel.addGradient(firstColor: UIColor(red: 0.298, green: 0.851, blue: 0.392, alpha: 1),
                               secondColor: UIColor(red: 0.18, green: 0.612, blue: 0.251, alpha: 1),
                               transform: CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))*/
    }
    
    //MARK:- Configure Video Player
    func configureVideoPlayer(user: RatingProfile) {
        removeVideoObserver()

        print("User's '\(user.name)' video:")
        print(user.video!)
        //let video = findUsersActiveVideo(user)
        
        video = user.video!.translatedToVideoType()
        if video.url != nil {
            //print(cell.video.url!)
            playerVC.player = AVPlayer(url: video.url!)
        } else {
            print("invalid url. cannot play video")
            return
        }
        
        playerVC.player?.seek(to: CMTime(seconds: user.video!.startTime, preferredTimescale: 1000))
        //cell.addVideoObserver()
        //cell.enableLoadingIndicator()
        
        //cell.playerVC.player?.play()
        
        //print(receivedVideo.length)
    }
    
    //MARK:- Remove All Video Observers
    func removeVideoObserver() {
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
    func addVideoObserver() {
        removeVideoObserver()
        
        //MARK:- Video Time Observer
        let interval = CMTimeMake(value: 1, timescale: 100)
        videoTimeObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            
            //MARK:- • stop video at specified time.
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
            case .failed:
                //self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                self?.replayButton.isHidden = false
            default:
                break
            }
        }
        
        //MARK: Video Did End Playing Observer
        videoDidEndPlayingObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerVC.player?.currentItem)
    }
    
    //MARK:- Video Did End
    @objc private func videoDidEnd() {
        //replayButton.isHidden = false
        playPauseButton.isHidden = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
        shouldReplay = true
    }
    
    //MARK:- Configure Loading Indicator
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
    
    //MARK:- Disable Loading Indicator
    func disableLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.isHidden = true
    }
    
    //MARK:- Update Play/Pause Button Image
    func updatePlayPauseButtonImage() {
        playPauseButton.setImage(UIImage(systemName:
            self.playerVC.player?.timeControlStatus == .playing ? "pause.fill" : "play.fill"
        ), for: .normal)

    }
    
    //MARK:- Update Contol Buttons Images
    func updateControls() {
        //playerVC.videoGravity = gravityMode
        let muteImg = Globals.isMuted ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.2.fill")
        let gravImg = playerVC.videoGravity == .resizeAspectFill ? UIImage(systemName: "rectangle.compress.vertical") : UIImage(systemName: "rectangle.expand.vertical")
        
        videoGravityButton.setImage(gravImg, for: .normal)
        muteButton.setImage(muteImg, for: .normal)
        updatePlayPauseButtonImage()
    }
    
    //MARK:- Hide ALL Controls
    func hideAllControls() {
        //replayButton.isHidden = true
        playPauseButton.isHidden = true
        muteButton.isHidden = true
        videoGravityButton.isHidden = true
    }
}
