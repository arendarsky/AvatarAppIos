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

class CastingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        castingView.dropShadow()
        configureButtons()
        configureVideoView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //playerVC.player?.play()
        replayButton.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerVC.player?.pause()
    }
    
    //server video request
    //old: let request = URLRequest(url: URL(string: "https://www.youtube.com/embed/3PlI6WUW4Kw?start=10")!)
    let testURL = "https://devstreaming-cdn.apple.com/videos/app_store/Seriously_Developer_Insight/Seriously_Developer_Insight_hd.mp4"
    lazy var receivedVideo = Video(stringURL: testURL, length: 30, startTime: 15, endTime: 45)
    lazy var serverURL = URL(string: testURL)
    //var player = AVPlayer(url: self.serverURL!)
    var playerVC = AVPlayerViewController()
    
    //@IBOutlet weak var videoWebView: WKWebView!
    @IBOutlet weak var castingView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var starName: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    
    //MARK:- Repeat Video
    @IBAction func repeatButtonPressed(_ sender: Any) {
        replayButton.isHidden = true
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1))
        playerVC.player?.play()
    }

    //MARK:- Show Full Video
    @IBAction func showFullVideoButtonPressed(_ sender: Any) {
        playerVC.player?.pause()
        playerVC.player?.seek(to: CMTime.zero)
        let fullScreenPlayer = AVPlayer(url: serverURL!)
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        
        present(fullScreenPlayerVC, animated: true) {
            fullScreenPlayer.play()
        }
    }
    
    //MARK:- Like & Dislike Button Actions
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
        //ternary operator to switch between button colors after pressing it
        likeButton.tintColor = (likeButton.tintColor == .systemRed ? .label : .systemRed)

        //and something else
    }
    

}

extension CastingViewController {
    //MARK:- Configure Button Views
    func configureButtons() {
        likeButton.addBlur()
        dislikeButton.addBlur()
        //likeButton.dropButtonShadow()
        //dislikeButton.dropButtonShadow()
        replayButton.isHidden = true
    }
    
    //MARK:- Configure Video View
    func configureVideoView() {
        let player = AVPlayer(url: serverURL!)
        //let playerVC = AVPlayerViewController()
        
        playerVC.player = player
        playerVC.view.frame = videoView.bounds
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 12
        playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        playerVC.view.backgroundColor = .quaternarySystemFill
        playerVC.showsPlaybackControls = false
        
        //MARK: present video from specified point:
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 1))
        
        //MARK: stop video at specified time. (Can also make progressView from here later)
        let interval = CMTimeMake(value: 1, timescale: 1)
        self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            print(currentTime)
            if currentTime >= (self?.receivedVideo.endTime)! {
                self?.playerVC.player?.pause()
                self?.replayButton.isHidden = false
            } else {
                self?.replayButton.isHidden = true
            }
        }
        
        //insert player into videoView
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.addSubview(playerVC.view)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
        playerVC.player?.play()
    }
    
}

private extension UIButton {
    func addBlur(){
        let blur = UIVisualEffectView(effect: UIBlurEffect(style:
            .regular))
        blur.frame = self.bounds
        blur.alpha = 0.9
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 0.5 * self.bounds.size.width
        blur.clipsToBounds = true
        self.addSubview(blur)
        self.bringSubviewToFront(self.imageView!)
    }
}
