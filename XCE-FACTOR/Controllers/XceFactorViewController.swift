//
//MARK:  XceFactorViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import NVActivityIndicatorView

///A base view controller for the app
class XceFactorViewController: UIViewController {
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) { return .default } else {
            return .lightContent
        }
    }
    
    //MARK: VC visibility
    var isCurrentlyVisible: Bool {
        return self.viewIfLoaded?.window != nil
    }
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTheme()
        configurations()
    }
    
    //MARK:- View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handlePossibleSoundError()
    }
    
    //MARK:- Load Theme
    ///Is used now to load dark theme on iOS 12 devices
    func loadTheme() {
        self.setNeedsStatusBarAppearanceUpdate()
        if #available(iOS 13, *) {
            
        } else {
            self.view.backgroundColor = .black
        }
    }
    
    //MARK:- Configurations
    func configurations() {
        //MARK:- color of back button for the NEXT vc on stack
        navigationItem.backBarButtonItem?.tintColor = .white
        
        let size = CGSize(width: 80, height: 80)
        let center = view.center
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(origin: center, size: size),
                                                        type: .circleStrokeSpin, color: .systemPurple, padding: 4.0)
        activityIndicatorView.addBlur()
        activityIndicatorView.layer.cornerRadius = 5
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
    
    //MARK:- Present Onboarding Pages
    ///Presents onboarding pages
    func presentOnboardingVC(relatedTo condition: Bool) {
        if condition, let vc = storyboard?.instantiateViewController(withIdentifier: "OnboardingPagesVC") as? OnboardingPagesVC {
            vc.parentVC = self
            vc.modalPresentationStyle = .overFullScreen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(vc, animated: true)
            }
        }
    }
    
    //MARK:- Show Info View Controller
    func presentInfoViewController(withHeader header: String?, infoAbout: InfoText, image: UIImage? = nil) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController {
            vc.header = header
            vc.infoImage = image
            vc.infoTextType = infoAbout
            
            vc.modalPresentationStyle = .automatic
            present(vc, animated: true)
        }
    }
    
    //MARK:- Info Text Types
    enum InfoText {
        case profile
        case rating
        case casting
        case notifications
    }

}
