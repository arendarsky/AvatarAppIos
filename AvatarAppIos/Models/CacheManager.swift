//
//MARK:  CacheManager.swift
//  AvatarAppIos
//
//  Created by Владислав on 11.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public enum CacheResult<T> {
    case success(T)
    case failure(String)
}

class CacheManager {

    static let shared = CacheManager()
    private let fileManager = FileManager.default

    private lazy var mainDirectoryUrl: URL = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()

    //MARK:- Get File With URL
    func getFileWith(fileUrl: URL?, completionHandler: @escaping (CacheResult<URL>) -> Void ) {
        guard let url = fileUrl else {
            completionHandler(.failure("CacheManager Error: Invalid URL"))
            return
        }

        let localFileUrl = directoryFor(url: url)

        //MARK:- return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: localFileUrl.path)  else {
            completionHandler(.success(localFileUrl))
            return
        }

        DispatchQueue.global().async {
            if let videoData = NSData(contentsOf: url) {
                videoData.write(to: localFileUrl, atomically: true)

                DispatchQueue.main.async {
                    completionHandler(CacheResult.success(localFileUrl))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(CacheResult.failure("CacheManager Error: Can't load file"))
                }
            }
        }
    }

    //MARK:- Create Local Url
    private func directoryFor(url: URL) -> URL {
        let fileName = url.lastPathComponent
        let fileUrl = self.mainDirectoryUrl.appendingPathComponent(fileName)

        return fileUrl
    }
}
