//
//MARK:  ViewControllerExtensions.swift
//  AvatarAppIos
//
//  Created by Владислав on 08.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import SafariServices

//MARK:- ====== UIViewController
///
///

public extension UIViewController {
    //MARK:- Configure Custom Navigation Bar
    ///by default configures with 'TopBar.png'
    func configureCustomNavBar(with image: UIImage? = nil, isBorderHidden: Bool = false, navBarImage: ((UIImageView, UIView?) -> Void)? = nil) {
        if let navController = navigationController {
            clearNavigationBar(forBar: navController.navigationBar, clearBorder: isBorderHidden)
            navController.view.backgroundColor = .clear
            
            let imageView = UIImageView(image: image ?? UIImage(named: "navbarDarkLong.png"))
            imageView.contentMode = .scaleToFill
            imageView.layer.masksToBounds = true
            imageView.isOpaque = false
            
            let blurView = UIView(frame: CGRect(x: 0, y: -2, width: imageView.frame.width, height: getHeaderImageHeightForCurrentDevice()))
            blurView.backgroundColor = UIColor.systemBackground//.withAlphaComponent(0.95)
            blurView.isOpaque = false
            //blurView.addBlur(alpha: 0.5)

            self.view.addSubview(blurView)
            self.view.addSubview(imageView)
            navBarImage?(imageView, blurView)

            imageView.translatesAutoresizingMaskIntoConstraints = false
            //blurView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -2),
                imageView.heightAnchor.constraint(equalToConstant: getHeaderImageHeightForCurrentDevice()),
                
                blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                blurView.topAnchor.constraint(equalTo: view.topAnchor, constant: -2),
                blurView.heightAnchor.constraint(equalToConstant: getHeaderImageHeightForCurrentDevice())
            ])
        }
    }
    
    func clearNavigationBar(forBar navBar: UINavigationBar, clearBorder: Bool) {
        navBar.backgroundColor = .clear
        navBar.setBackgroundImage(UIImage(), for: .default)
        //⬇️ makes navbar border invisible
        if clearBorder {
            navBar.shadowImage = UIImage()
        }
        navBar.isTranslucent = true
        navBar.isOpaque = false
        navBar.layoutIfNeeded()
    }
    
    //MARK:- NavBar Image Height
    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
        // iPhone X-style
        case 2436, 2688, 1792:
            return 90
//        //iPhone 5s-style
//        case 1136:
//            return 60
        // Any other iPhone
        default:
            return 64
        }
    }
    
    //MARK:- Find Active Video
    /** returns the first active video of User's video list
     
     ❗️works only for Users with non-empty video lists❗️
     */
    func findUsersActiveVideo(_ user: User) -> Video? {
        for video in user.videos {
            if video.isActive {
                return video.translatedToVideoType()
            }
        }
        return nil
    }
    
    //MARK:- Open Safari View Controller
    enum LinkType {
        case termsOfUse
        case privacyPolicyAtGoogleDrive
        case other(String)
    }
    
    ///opens safari screen with purple toolbars
    func openSafariVC(_ delegate: SFSafariViewControllerDelegate, with linkType: LinkType, autoReaderView: Bool = true) {
        var link = ""
        switch linkType {
        case .termsOfUse:
            link = "https://xce-factor.ru/TermsOfUse.html"
        case .privacyPolicyAtGoogleDrive:
            link = "https://docs.google.com/document/d/1Xp7hDzkffP23SJ4aQcOlkEXAdDy79MMKpGk9-kct6RQ"
        case let .other(path):
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
        
        if #available(iOS 13.0, *) {
        } else {
            let color = UIColor.darkGray.withAlphaComponent(0.5)
            left.backgroundColor = color
            right.backgroundColor = color
        }
        
    }
    
    //MARK:- Set App Root ViewController
    func setApplicationRootVC(storyboardID: String, animation: UIView.AnimationOptions? = .transitionFlipFromRight) {
        guard
            let vc = self.storyboard?.instantiateViewController(withIdentifier: storyboardID),
            let window = UIApplication.shared.windows.first
        else { return }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
        if animation != nil {
            UIView.transition(with: window, duration: 0.3, options: [.preferredFramesPerSecond60, animation!], animations: nil, completion: nil)
        }
        
    }
    
    //MARK:- Set New Root VC in NavController
    func setNavigationControllerRootVC(storyboardID id: String, animated: Bool = true, isNavBarHidden: Bool = true) {
        guard let newVC = storyboard?.instantiateViewController(withIdentifier: id) else {
            debugPrint("Error instantiating ViewController")
            return
        }
        let newViewControllers: [UIViewController] = [newVC]
        self.navigationController?.navigationBar.isHidden = isNavBarHidden
        self.navigationController?.setViewControllers(newViewControllers, animated: animated)
    }
    
    //MARK:- Update User Data
    /**Updates fields 'name', 'description', 'likesNumber' and 'videosCount' for existing Globals.user instance
        
    does not create any new objects
     */
    func updateUserData(with newData: UserProfile) {
        Globals.user.videosCount = newData.videos?.count
        Globals.user.name = newData.name
        Globals.user.description = newData.description ?? ""
        Globals.user.likesNumber = newData.likesNumber ?? 0
    }
    
}
