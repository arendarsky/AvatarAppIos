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
        vcPlayer.player!.play()
    }
}
