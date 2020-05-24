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
    static func presentShareMenu(for videoUrl: URL, delegate: UIViewController) {
        let fileToShare = [videoUrl]
    
        let shareSheetVC = UIActivityViewController(activityItems: fileToShare, applicationActivities: nil)
        delegate.present(shareSheetVC, animated: true)
    }
    
    //MARK:- Generate Video URL
    static func generateWebUrl(from videoName: String?) -> URL? {
        guard let name = videoName else {
            return nil
        }
        return URL(string: "\(Globals.webDomain)/#/video/\(name)")
    }
    
}
