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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePlayer()
        nextStepButton.configureBackgroundColors()

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
        let player = AVPlayer(url: self.video.URL!)
        let vcPlayer = AVPlayerViewController()
        vcPlayer.player = player
        vcPlayer.view.frame = videoView.bounds
        vcPlayer.view.layer.cornerRadius = 16
        vcPlayer.view.backgroundColor = .quaternarySystemFill
        
        self.addChild(vcPlayer)
        vcPlayer.didMove(toParent: self)
        videoView.addSubview(vcPlayer.view)
        videoView.backgroundColor = .clear
        vcPlayer.entersFullScreenWhenPlaybackBegins = true
        vcPlayer.exitsFullScreenWhenPlaybackEnds = true
        //vcPlayer.player!.play()
    }
}
