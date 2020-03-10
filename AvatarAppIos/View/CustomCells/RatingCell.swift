//
//  RatingCell.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import NVActivityIndicatorView

class RatingCell: UICollectionViewCell {
    
    var playerVC = AVPlayerViewController()
    var video = Video()
    var videoTimeObserver: Any?
    var videoDidEndPlayingObserver: Any?
    var loadingIndicator: NVActivityIndicatorView?
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        addTapGestureRecognizer()
    }
    
    
    @IBAction func replayButtonPressed(_ sender: Any) {
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 600))
        playerVC.player?.play()
        replayButton.isHidden = true
    }
    
    //MARK:- Play/Pause Button Pressed
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if playerVC.player?.timeControlStatus == .playing {
            playerVC.player?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playerVC.player?.play()
        }
        playPauseButton.setButtonWithAnimation(in: videoView, hidden: true, startDelay: 0.3, duration: 0.2)
    }
    
    
    //MARK:- Show/Hide Play Button on Tap
    @objc func handleTapGesture(sender: UITapGestureRecognizer) {
        if playPauseButton.isHidden {
            if self.playerVC.player?.timeControlStatus == .playing {
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }else{
                playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
            playPauseButton.setButtonWithAnimation(in: videoView, hidden: false, duration: 0.2)
        } else {
            playPauseButton.setButtonWithAnimation(in: videoView, hidden: true, duration: 0.2)
        }
        
    }
    
    func addTapGestureRecognizer() {
        videoView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapRecognizer.numberOfTapsRequired = 1
        videoView.addGestureRecognizer(tapRecognizer)
    }
    
}

extension RatingCell {
    func configureCell() {
        profileImageView.layer.cornerRadius = 15

        videoView.layer.cornerRadius = 25
        videoView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        descriptionView.layer.cornerRadius = 25
        descriptionView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        playPauseButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        replayButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
                self?.replayButton.isHidden = false
            } else {
                self?.disableLoadingIndicator()
                self?.replayButton.isHidden = currentTime < self!.video.endTime
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
                //self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
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
}
