//
//MARK:  CacheManager.swift
//  AvatarAppIos
//
//  Created by Владислав on 11.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import Alamofire

enum CacheResult<T> {
    case success(T)
    case failure(SessionError)
}

class CacheManager {

    static let shared = CacheManager()
    private let fileManager = FileManager.default

    private lazy var mainDirectoryUrl: URL = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()
    
    //MARK:- Get Local Url if Exists
    func getLocalIfExists(at fileUrl: URL?) -> URL? {
        guard let url = fileUrl else {
            return nil
        }

        let localFileUrl = directoryFor(url: url)
        
        if fileManager.fileExists(atPath: localFileUrl.path) {
            return localFileUrl
        }
        return nil
    }
    
    //MARK:- Cache File w/Alamofire
    ///Cache File w/Alamofire
    func getFile(with fileUrl: URL?, timeout: Double? = nil, completion: @escaping ((CacheResult<URL>) -> Void), request: ((DownloadRequest) -> Void)?) {
        guard let url = fileUrl else {
            completion(.failure(.invalidUrl))
            return
        }
        
        let localFileUrl = directoryFor(url: url)

        //MARK:- return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: localFileUrl.path)  else {
            completion(.success(localFileUrl))
            return
        }
        
        let destination: DownloadRequest.Destination = { _, _ in
            return (localFileUrl, [.createIntermediateDirectories, .removePreviousFile])
        }
        
        let downloadRequest = AF.download(url, to: destination).response { response in
            if let error = response.error {
                DispatchQueue.main.async {
                    completion(.failure(.local(error)))
                }
                return
            }
            
            guard let url = response.fileURL else {
                DispatchQueue.main.async {
                    completion(.failure(.serverError))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(url))
            }
        }
        
        request?(downloadRequest)
        
    }
    
    //MARK:- Resume Caching
    func resumeCaching(_ resumeData: Data, completion: @escaping ((CacheResult<URL>) -> Void)) {
        AF.download(resumingWith: resumeData).response { response in
            switch response.result {
            case.failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completion(.failure(.local(error)))
                }
                return
            case.success(_):
                DispatchQueue.main.async {
                    guard let url = response.fileURL else {
                        completion(.failure(.dataError))
                        return
                    }
                    completion(.success(url))
                }
                return
            }
        }
    }
    
    //MARK:- Cache File With URL
    func getFileWith(fileUrl: URL?, specifiedTimeout: Double? = nil, completionHandler: @escaping (CacheResult<URL>) -> Void ) {
        guard let url = fileUrl else {
            completionHandler(.failure(.invalidUrl))
            return
        }

        let localFileUrl = directoryFor(url: url)

        //MARK:- return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: localFileUrl.path)  else {
            completionHandler(.success(localFileUrl))
            return
        }
        
        //TODO: probably make it background
        let cfg = URLSessionConfiguration.default
        if let timeout = specifiedTimeout {
            //cfg.timeoutIntervalForRequest = timeout
            cfg.timeoutIntervalForResource = timeout
        }
        let cacheSession = URLSession(configuration: cfg)

        //MARK:- Cache Session
        cacheSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.failure(.local(error)))
                }
                return
            }
            guard let fileData = data else {
                DispatchQueue.main.async {
                    completionHandler(CacheResult.failure(.serverError))
                }
                return
            }
            
            do {
                //MARK:- Writing to url
                try fileData.write(to: localFileUrl, options: [.atomic])
                DispatchQueue.main.async {
                    completionHandler(CacheResult.success(localFileUrl))
                }
                return
            } catch {
                DispatchQueue.main.async {
                    completionHandler(CacheResult.failure(.writingError))
                }
                return
            }

        }.resume()
        
    }

    //MARK:- Create Local Url
    private func directoryFor(url: URL) -> URL {
        let fileName = url.lastPathComponent
        let fileUrl = self.mainDirectoryUrl.appendingPathComponent(fileName)

        return fileUrl
    }
}
