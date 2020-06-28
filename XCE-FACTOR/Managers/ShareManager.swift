//
//  ShareManager.swift
//  XCE-FACTOR
//
//  Created by Владислав on 22.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ShareManager {
    
    //MARK:- Present Share Menu
    static func presentShareSheetVC(for video: Video, delegate: UIViewController) {
        guard let webUrl = generateWebUrl(from: video.name), let apiUrl = video.url else {
            print("Web URL generating Error")
            return
        }
        let fileToShare = [webUrl]
        
        var appActions: [UIActivity]?

        if let url = CacheManager.shared.getLocalIfExists(at: apiUrl) {
            let shareToInstagram = CustomShareActivity(
                title: "Поделиться в Instagram",
                image: IconsManager.getIcon(.instagramLogo),
                items: []) { (items) in
                    self.shareToInstagramStories(videoUrl: url, delegate)
            }
            appActions = [shareToInstagram]
        }

    
        let shareSheetVC = UIActivityViewController(activityItems: fileToShare, applicationActivities: appActions)
        //for ipads not to crash
        shareSheetVC.popoverPresentationController?.sourceView = delegate.view
        
        delegate.present(shareSheetVC, animated: true)
        
    }
    
    //MARK:- Generate Video Web URL
    static func generateWebUrl(from videoName: String?) -> URL? {
        guard let name = videoName else {
            return nil
        }
        return URL(string: "\(Globals.webDomain)/#/video/\(name)")
    }
    
    //MARK:- Open Instagram Profile
    static func openInstagramProfile(_ nickname: String) {
        guard let appURL = URL(string: "instagram://user?username=\(nickname)"),
            let webURL = URL(string: "https://instagram.com/\(nickname)") else {
                print("invalid instagram profile URL")
                return
        }
        //instagram has universal links so we don't have to manage app links
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    //MARK:- Share Video To Instagram
    static func shareToInstagramStories(videoUrl: URL?, _ delegate: UIViewController?) {
        
        guard let storiesUrl = URL(string: "instagram-stories://share"), UIApplication.shared.canOpenURL(storiesUrl) else {
            print("Instagram is not installed or the url is incorrect")
            delegate?.showSimpleAlert(title: "Не удалось открыть Instagram", message: "Поделиться в Stories можно только из мобильного приложения. Скорее всего, оно у вас не установлено")
            return
        }
        
        guard let localVideoUrl = CacheManager.shared.getLocalIfExists(at: videoUrl) else {
            print("File is not saved locally")
            return
        }
        
        guard let videoData = NSData(contentsOf: localVideoUrl) else {
            print("Incorrect video data")
            return
        }
        
        let videoItems: [String : Any] = [
            "com.instagram.sharedSticker.backgroundVideo" : videoData
        ]
        
        let pasteboardOptions: [UIPasteboard.OptionsKey : Any] = [
            .expirationDate : Date().addingTimeInterval(300)
        ]
        
        UIPasteboard.general.setItems([videoItems], options: pasteboardOptions)
        UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
        
    }
    
}
