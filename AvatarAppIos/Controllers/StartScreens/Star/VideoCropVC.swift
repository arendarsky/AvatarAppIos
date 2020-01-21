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
    var videoURL: URL?
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        //nothing for now
    }
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player = AVPlayer(url: self.videoURL!)
        let vcPlayer = AVPlayerViewController()
        vcPlayer.player = player
        vcPlayer.view.frame = videoView.bounds
        self.addChild(vcPlayer)
        videoView.addSubview(vcPlayer.view)
        vcPlayer.didMove(toParent: self)
        videoView.backgroundColor = .clear
        vcPlayer.player!.play()
    }

}
