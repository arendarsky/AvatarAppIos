//
//MARK:  XFSharingToInstagram.swift
//  XCE-FACTOR
//
//  Created by Владислав on 24.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

extension XceFactorViewController {
    
    //MARK:- Prepare Video and Share
    func prepareAndShareToStories(videoUrl: URL?, enableActivityHandler: (() -> Void)?, disableActivityHandler: (() -> Void)?) {
        
        if let url = CacheManager.shared.getLocalIfExists(at: videoUrl) {
            ShareManager.shareToInstagramStories(videoUrl: url, self)
        } else {
            enableActivityView()
            enableActivityHandler?()
            print("downloading video in rating for stories")
            loadVideoXF(with: videoUrl) { (downloadedUrl) in
                self.disableActivityView()
                disableActivityHandler?()
                guard let url = downloadedUrl else {
                    print("failed to download a video in rating")
                    return
                }
                ShareManager.shareToInstagramStories(videoUrl: url, self)
            }
        }
    }
    
    //MARK:- Load Video
    func loadVideoXF(with url: URL?, completion: @escaping ((URL?) -> Void)) {
        CacheManager.shared.getFile(with: url, completion: { (result) in
            switch result {
            case.failure(let sessionError):
                print(sessionError)
                if !(self.downloadRequestXF?.isCancelled ?? true) {
                    self.showErrorConnectingToServerAlert(title: "Не удалось поделиться", message: "Не удалось связаться с сервером для отправки видео в Instagram. Попробуйте поделиться ещё раз")
                }
                completion(nil)
            case.success(let cachedUrl):
                completion(cachedUrl)
            }
        }) { (downloadRequest) in
            self.downloadRequestXF = downloadRequest
        }
    }
    
}
