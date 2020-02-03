//
//  VideoCropVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 21.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

class VideoCropVC: UIViewController {
    var video = Video()
    lazy var player = AVPlayer(url: video.url!)
    var playerVC = AVPlayerViewController()
    //var lastChange = "u"
    
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var nextStepButton: UIButton!
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        //nothing for now
    }
    @IBAction func uploadAnotherVideoButtonPressed(_ sender: Any) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    @IBOutlet weak var videoView: UIView!
    @IBAction func rangeSliderValueChanged(_ sender: RangeSlider) {
        playerVC.player?.pause()
        if rangeSlider.upperValue == video.endTime{
            playerVC.player?.seek(to: CMTime(seconds: rangeSlider.lowerValue, preferredTimescale: 100))
            self.video.startTime = rangeSlider.lowerValue
        }else{
            playerVC.player?.seek(to: CMTime(seconds: rangeSlider.upperValue, preferredTimescale: 100))
            self.video.endTime = rangeSlider.upperValue
        }
        print("start: \(video.startTime)\nend: \(video.endTime)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePlayer()
        nextStepButton.configureBackgroundColors()
        
        //autoconfiguration of rangeSlider
        if video.url != nil {
            rangeSlider.maximumValue = video.length
            if video.length > 30 {
                rangeSlider.lowerValue = video.length / 2 - 15
                rangeSlider.upperValue = video.length / 2 + 15
            } else {
                rangeSlider.lowerValue = 0
                rangeSlider.upperValue = video.length
            }
            video.startTime = rangeSlider.lowerValue
            video.endTime = rangeSlider.upperValue
            //print(rangeSlider.maximumValue)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
}

private extension VideoCropVC {
    func configurePlayer(){
        //let player = AVPlayer(url: self.video.URL!)
        //let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.view.frame = videoView.bounds
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 16
        playerVC.view.backgroundColor = .quaternarySystemFill
        
        //present video from specified point:
        //playerVC.player!.seek(to: CMTime(seconds: 1, preferredTimescale: 1))
        
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.addSubview(playerVC.view)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        playerVC.exitsFullScreenWhenPlaybackEnds = true
        playerVC.player?.play()
    }
}
