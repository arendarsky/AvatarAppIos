//
//  AvatarAppIos
//
//  Created by Владислав on 08.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import SafariServices

public extension UIViewController {

    // MARK: - Enums

    enum LinkType {
        case termsOfUse, privacyPolicyAtGoogleDrive
        case unspecified(String)
        
        var stringLink: String {
            switch self {
            case .privacyPolicyAtGoogleDrive:
                return "https://docs.google.com/document/d/1Xp7hDzkffP23SJ4aQcOlkEXAdDy79MMKpGk9-kct6RQ"
            case .termsOfUse:
                return "https://xce-factor.ru/TermsOfUse.html"
            case let .unspecified(link):
                return link
            }
        }
    }

    // MARK: - Extensions

    /// By default configures with 'TopBar.png'
    func configureCustomNavBar(with image: UIImage? = nil,
                               isBorderHidden: Bool = false,
                               navBarImage: ((UIImageView, UIView?) -> Void)? = nil) {
        guard let navController = navigationController else { return }

        clearNavigationBar(forBar: navController.navigationBar, clearBorder: isBorderHidden)
        navController.view.backgroundColor = .clear
        
        let imageView = UIImageView(image: image ?? UIImage(named: "navbarDarkLong.png"))
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        imageView.isOpaque = false
        
        let blurView = UIView(frame: CGRect(x: 0, y: -2,
                                            width: imageView.frame.width,
                                            height: getHeaderImageHeightForCurrentDevice()))
        blurView.backgroundColor = UIColor.systemBackground
        blurView.isOpaque = false

        view.addSubview(blurView)
        view.addSubview(imageView)
        navBarImage?(imageView, blurView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
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
    
    func clearNavigationBar(forBar navBar: UINavigationBar?, clearBorder: Bool) {
        guard let navBar = navBar else { return }

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

    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
        // iPhone X-style
        case 2436, 2532, 2688, 2778, 1792:
            return 90
        // Any other iPhone
        default:
            return 64
        }
    }

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
    
    //MARK: - Open Safari VC with link
    ///Opens Safari screen with chosen preset link or any other given
    func openSafariVC(_ delegate: SFSafariViewControllerDelegate, with linkType: LinkType, autoReaderView: Bool = true, barsColor: UIColor = .purple) {

        guard let url = URL(string: linkType.stringLink) else { return }
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = autoReaderView
        
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.delegate = delegate
        vc.preferredControlTintColor = .white
        vc.preferredBarTintColor = barsColor
        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .automatic
            vc.isModalInPresentation = true
        } else {
            vc.modalPresentationStyle = .pageSheet
        }
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - Add Corner Radius to 2 UIViews as One
    func roundTwoViewsAsOne(left: UIView, right: UIView, cornerRadius: CGFloat) {
        left.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        right.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        left.layer.cornerRadius = cornerRadius
        right.layer.cornerRadius = cornerRadius
        
        if #available(iOS 13.0, *) {} else {
            let color = UIColor.darkGray.withAlphaComponent(0.5)
            left.backgroundColor = color
            right.backgroundColor = color
        }
    }
    
    //MARK: - Set App Root ViewController
    func setApplicationRootVC(storyboardID: String, transition: UIView.AnimationOptions? = .transitionFlipFromRight) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: storyboardID),
              let window = UIApplication.shared.windows.first else { return }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()

        if let transition = transition {
            UIView.transition(with: window, duration: 0.3, options: [.preferredFramesPerSecond60, transition], animations: nil, completion: nil)
        }
    }
    
    //MARK: - Set New Root VC in NavController
    func setNavigationControllerRootVC(storyboardID id: String, animated: Bool = true, isNavBarHidden: Bool = true) {
        guard let newVC = storyboard?.instantiateViewController(withIdentifier: id) else {
            debugPrint("Error instantiating ViewController")
            return
        }
        let newViewControllers: [UIViewController] = [newVC]
        self.navigationController?.navigationBar.isHidden = isNavBarHidden
        self.navigationController?.setViewControllers(newViewControllers, animated: animated)
    }
    
    //MARK: - Update User Data
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
