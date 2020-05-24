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
    private static let (userTokenKey, emailKey) = ("token", "email")
    private static let userSessionKey = "com.save.usersession"
    private static let appLaunchedBeforeKey = "com.save.appLaunchedBefore"
    private static let fcmTokenKey = "com.save.fcmToken"
    
    private static let userDefault = UserDefaults.standard
    
    //MARK:- User Info
    struct UserDetails {
        let token: String
        let email: String
        
        init(_ json: [String: String]) {
            self.token = json[userTokenKey] ?? ""
            self.email = json[emailKey] ?? ""
        }
    }
    
    static var wasAppLaunchedBefore: Bool {
        get {
            Defaults.userDefault.bool(forKey: Defaults.appLaunchedBeforeKey)
        }
        set {
            Defaults.userDefault.set(newValue, forKey: Defaults.appLaunchedBeforeKey)
        }
    }
    
    static func getFcmToken() -> String {
        if let token = Defaults.userDefault.string(forKey: fcmTokenKey) {
            return token
        }
        return ""
    }
    
    static func setFcmToken(_ token: String) {
        Defaults.userDefault.set(token, forKey: fcmTokenKey)
    }
    
    static func save(token: String, email: String){
        userDefault.set(
            [userTokenKey: token,
             emailKey: email],
            forKey: userSessionKey)
    }
    
    static func getUserData() -> UserDetails {
        return UserDetails((userDefault.value(forKey: userSessionKey) as? [String: String]) ?? [:])
    }
    
    static func clearUserData(){
        userDefault.removeObject(forKey: userSessionKey)
        userDefault.removeObject(forKey: fcmTokenKey)
    }
}
