//
//  Defaults.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

struct Defaults {
    ///only 2 fields as for now. later will be added: videosCount, isMuted, likesNumber
    static let (tokenKey, emailKey) = ("token", "email")
    static let userSessionKey = "com.save.usersession"
    static let appLaunchedBefore = "com.save.appLaunchedBefore"
    private static let userDefault = UserDefaults.standard
    
    struct UserDetails {
        let token: String
        let email: String
        
        init(_ json: [String: String]) {
            self.token = json[tokenKey] ?? ""
            self.email = json[emailKey] ?? ""
        }
    }
    
    static var wasAppLaunchedBefore: Bool {
        get {
            Defaults.userDefault.bool(forKey: Defaults.appLaunchedBefore)
        }
        set {
            Defaults.userDefault.set(newValue, forKey: Defaults.appLaunchedBefore)
        }
    }
    
    static func save(token: String, email: String){
        userDefault.set(
            [tokenKey: token,
             emailKey: email],
            forKey: userSessionKey)
    }
    
    static func getData() -> UserDetails {
        return UserDetails((userDefault.value(forKey: userSessionKey) as? [String: String]) ?? [:])
    }
    
    static func clearUserData(){
        userDefault.removeObject(forKey: userSessionKey)
    }
}
