//
//  Globals.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

//server domains:
//"https://xce-factor.ru"
//"https://avatarapp.yambr.ru"
//"https://avatarappapi.azurewebsites.net"

//MARK:- Important global values for application funcs
public struct Globals {
    
    static let domain = "https://xce-factor.ru"
    static let webDomain = "https://web.xce-factor.ru"
    static let baseUrlComponent = URLComponents(string: domain)!
    static var isFirstAppLaunch = true
    static var notificationsTabBarItem: UITabBarItem?
    
    static let maxVideosAllowed = 5
    static var user = UserAccount()
    static var isMuted = false
    static var isNewLike = false
}
