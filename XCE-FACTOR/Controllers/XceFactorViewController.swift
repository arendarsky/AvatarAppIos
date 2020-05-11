//
//MARK:  XceFactorViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit

///A base view controller for the app
class XceFactorViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .default } else {
            return .lightContent
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTheme()
        handlePossibleSoundError()
    }
    
    //MARK:- Load Theme
    func loadTheme() {
        self.setNeedsStatusBarAppearanceUpdate()
        if #available(iOS 13, *) {
            
        } else {
            self.view.backgroundColor = .black
        }
    }
    
    //MARK:- Handle Possible Sound Error
    func handlePossibleSoundError() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            //try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }

}
