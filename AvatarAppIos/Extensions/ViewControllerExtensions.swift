//
//MARK:  ViewControllerExtensions.swift
//  AvatarAppIos
//
//  Created by Владислав on 08.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import SafariServices
import AVKit

//MARK:- ====== UIViewController
///
///

public extension UIViewController {
    //MARK:- Handle Possible Sound Error
    func handlePossibleSoundError() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    //MARK:- Configure Custom Navigation Bar
    ///by default configures with 'TopBar.png'
    func configureCustomNavBar(with image: UIImage? = nil) {
        if let navController = navigationController {
            clearNavigationBar(forBar: navController.navigationBar)
            navController.navigationBar.backgroundColor = .clear
            navController.view.backgroundColor = .clear
            
            let imageView = UIImageView(image: image ?? UIImage(named: "TopBar.png"))
            imageView.contentMode = .scaleToFill
            self.view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -2),
                imageView.heightAnchor.constraint(equalToConstant: getHeaderImageHeightForCurrentDevice())
            ])
        }
    }
    
    func clearNavigationBar(forBar navBar: UINavigationBar) {
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
    }
    
    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
        // iPhone X-style
        case 2436, 2688, 1792:
            return 90
        // Any other iPhone
        default:
            return 66
        }
    }
    
    //MARK:- Find Active Video
    /** returns the first active video of user's video list
     ❗️works only for Users with non-empty video lists❗️
     */
    func findUsersActiveVideo(_ user: User) -> Video {
        let res = Video()
        for video in user.videos {
            if video.isActive {
                res.name = video.name
                res.startTime = video.startTime / 1000
                res.endTime = video.endTime / 1000
                res.url = URL(string: "\(Globals.domain)/api/video/" + video.name)
                print("start:", res.startTime, "end:", res.endTime)
                break
            }
        }
        return res
    }
    
    //MARK:- Open Safari View Controller
    enum LinkType {
        case termsOfUse
        case privacyPolicyAtGoogleDrive
        case other(String)
    }
    
    func openSafariVC(with linkType: LinkType, delegate: SFSafariViewControllerDelegate, autoReaderView: Bool = false) {
        var link = ""
        switch linkType {
        case .termsOfUse:
            link = "https://xce-factor.ru/TermsOfUse.html"
        case .privacyPolicyAtGoogleDrive:
            link = "https://docs.google.com/document/d/1Xp7hDzkffP23SJ4aQcOlkEXAdDy79MMKpGk9-kct6RQ"
        case .other(let path):
            link = path
        }
        guard let url = URL(string: link) else { return }
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = autoReaderView
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.delegate = delegate
        vc.preferredControlTintColor = .white
        vc.preferredBarTintColor = .purple
        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .automatic
            vc.isModalInPresentation = true
        } else {
            vc.modalPresentationStyle = .pageSheet
        }
        present(vc, animated: true, completion: nil)
    }
    
    //MARK:- Add Corner Radius to 2 UIViews as One
    func roundTwoViewsAsOne(left: UIView, right: UIView, cornerRadius: CGFloat) {
        left.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        right.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        
        left.layer.cornerRadius = cornerRadius
        right.layer.cornerRadius = cornerRadius
        
    }
    
    //MARK:- Set New Root View Controller and show it
    /// shows MainTabBarController as a default
    func presentNewRootViewController(storyboardIdentifier id: String = "MainTabBarController", animated: Bool = true, isNavBarHidden: Bool = true) {
        guard let newVC = storyboard?.instantiateViewController(withIdentifier: id) else {
            debugPrint("Error instantiating ViewController")
            return
        }
        
        //MARK:- ⬇️ Below we can see 3 different options for presenting Casting Screen:
        ///1) Just present it modally in fullscreen
        ///   + good animation
        ///   - the welcoming screen after presentation still stays in memory and that's very bad
        
        //newVC.modalPresentationStyle = .fullScreen
        //present(newVC, animated: true, completion: nil)
        
        ///2) Change Root View Controller to the Casting Screen
        ///   +++ good for memory
        ///   - no animation.
        /*
        UIApplication.shared.windows.first?.rootViewController = newVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
         */
        
        ///3) Set New Array of Controllers of NavController ❗️(Using Now)❗️
        ///   + good for memory
        ///   - animation is quite simple
        ///   - have to hide Navigation Bar manually in order to keep correct layout.
        ///         This might result in some problems in the future if we would need to open smth from Casting Screen
        
        let newViewControllers: [UIViewController] = [newVC]
        self.navigationController?.navigationBar.isHidden = isNavBarHidden
        self.navigationController?.setViewControllers(newViewControllers, animated: animated)
    }
}
