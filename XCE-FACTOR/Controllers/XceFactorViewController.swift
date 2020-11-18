//
//MARK:  XceFactorViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import Alamofire

///A base view controller for the app
class XceFactorViewController: UIViewController {
    
    weak var downloadRequestXF: DownloadRequest?
    
    private var activityView: ActivityView?
    
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
        // color of back button for the NEXT vc on stack
        navigationItem.backBarButtonItem?.tintColor = .white
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
    
    
    //MARK:- Configure ActivityView
    ///if you want to use activity view, you must call this method in your subclass of xcefactorVC first. Otherwise, it won't work
    func configureActivityView(dismissHandler: (() -> Void)? = nil) {
        guard activityView == nil else { return }

        let size = CGSize(width: 240, height: 120)
        let rect = CGRect(origin: view.center, size: size)

        activityView = ActivityView(frame: rect)
        if let activityView = activityView {
            view.addSubview(activityView)

            activityView.configure()
            activityView.backgroundColor = .clear
            activityView.addBlur(style: .regular)
            
            activityView.addTapGestureRecognizer() {
                self.activityView?.setViewWithAnimation(in: self.view, hidden: true, duration: 0.3)
                dismissHandler?()
            }
        }
    }
    
    //MARK:- Enable Activity View
    func enableActivityView() {
        activityView == nil
            ? print("❗️Activity View is not configured")
            : activityView?.setViewWithAnimation(in: view, hidden: false, duration: 0.3)
    }
    
    //MARK:- Disable Activity View
    func disableActivityView() {
        activityView?.isHidden = true
    }
    
    //MARK:- Info Text Types
    enum InfoText {
        case profile
        case rating
        case casting
        case notifications
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
    
}
