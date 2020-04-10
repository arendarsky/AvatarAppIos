//
//  CacheManager.swift
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

    func getFileWith(fileUrl: URL?, completionHandler: @escaping (CacheResult<URL>) -> Void ) {
        guard let url = fileUrl else {
            return
        }

        let file = directoryFor(url: url)

        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path)  else {
            completionHandler(CacheResult.success(file))
            return
        }

        DispatchQueue.global().async {

            if let videoData = NSData(contentsOf: url) {
                videoData.write(to: file, atomically: true)

                DispatchQueue.main.async {
                    completionHandler(CacheResult.success(file))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(CacheResult.failure("Can't download video"))
                }
            }
        }
    }

    private func directoryFor(url: URL) -> URL {

        let fileURL = url.lastPathComponent

        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)

        return file
    }
}
