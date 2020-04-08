//
//  System.swift
//  AvatarAppIos
//
//  Created by Владислав on 23.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public class System {
    
    //MARK:- Clear all files in Document Directory
    static func clearAllFiles() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try fileManager.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
    
    //MARK:- Delete file at specified url
    static func deleteAtUrl(fileUrl: URL?) {
        guard let url = fileUrl else {
            print(">>>> Invalid file url")
            return
        }
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("Error deleting")
            return
        }
    }
    
    //MARK:- Clear all Documents Directory in background
    static func clearance() {
        DispatchQueue.global(qos: .utility).async {
            clearAllFiles()
            DispatchQueue.main.async {
                print("Data clearance complete")
            }
        }
    }
}
