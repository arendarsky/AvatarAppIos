//
//  System.swift
//  AvatarAppIos
//
//  Created by Владислав on 23.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public class System {
    
    static func clearAllFiles() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try fileManager.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
}
