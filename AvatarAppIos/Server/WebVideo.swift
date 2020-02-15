//
//  WebVideo.swift
//  AvatarAppIos
//
//  Created by Владислав on 07.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public class WebVideo {
    
    static func getUrl() -> String {
        var videoUrl = ""
        let serverPath = "https://avatarappapi20200123093213.azurewebsites.net/api/admin/get_video"
        let serverUrl = URL(string: serverPath)!
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "POST"
        
        return videoUrl
    }
}
