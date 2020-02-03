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
        print("videoView.bounds = \(videoView.bounds)")
        print("videoView.frame = \(videoView.frame)")
        print("playerVC.view.frame = \(playerVC.view.frame)")
        print("playerVC.view.bounds = \(playerVC.view.bounds)")
        configureVideoView()
       // configureWebView()
       // videoWebView.load(request)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //playerVC.player?.play()
        replayButton.isHidden = false
    }
    
    //server video request
    //old: let request = URLRequest(url: URL(string: "https://www.youtube.com/embed/3PlI6WUW4Kw?start=10")!)
    let testURL = "https://scontent-arn2-1.cdninstagram.com/v/t50.2886-16/85355992_3117007098350229_3619538964017182337_n.mp4?_nc_ht=scontent-arn2-1.cdninstagram.com&_nc_cat=109&_nc_ohc=N4CLCHnUIhgAX8lDWos&oe=5E3A68CA&oh=4cc34f490e1c6735ef5039469de6d4b2"
    lazy var receivedVideo = Video(stringURL: testURL, length: 30, startTime: 0, endTime: 15)
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
        playerVC.player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
        let fullScreenPlayer = AVPlayer(url: serverURL!)
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        
        present(fullScreenPlayerVC, animated: true) {
            fullScreenPlayer.play()
        }
    }
    
    //MARK:- Like & Dislike Buttons
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
        if likeButton.tintColor == .systemRed {
            likeButton.tintColor = .darkGray
        } else {
            likeButton.tintColor = .systemRed
        }
        //and something else
    }
    

}

extension CastingViewController {
    func configureButtons() {
        likeButton.dropButtonShadow()
        dislikeButton.dropButtonShadow()
        replayButton.isHidden = true
    }
    
    //MARK:- Configure Video View
    func configureVideoView() {
        let player = AVPlayer(url: serverURL!)
        //let playerVC = AVPlayerViewController()
        
        playerVC.player = player
        playerVC.view.frame = videoView.bounds
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 16
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
    
    
    //old
  /*  func configureWebView() {
        videoWebView.backgroundColor = .clear
        videoWebView.clipsToBounds = true
        //videoWebView.layer.masksToBounds = true
        videoWebView.layer.cornerRadius = 16
        videoWebView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }*/
}
