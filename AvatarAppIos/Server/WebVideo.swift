//
//  WebVideo.swift
//  AvatarAppIos
//
//  Created by Владислав on 07.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import Alamofire

public class WebVideo {

    //MARK:- Get Videos from Server using admin property
    static func getUrls_Admin(completion: @escaping (Result<[String]>) -> Void) {
        //let numberOfVideos = 100
        let serverPath = "\(domain)/api/admin/get_videos?number=\(100)"
        let serverUrl = URL(string: serverPath)!
        var request = URLRequest(url: serverUrl)
        var videoUrls = [String]()

        request.setValue("text/plain", forHTTPHeaderField: "accept")
        request.setValue(authKey, forHTTPHeaderField: "Authorization")

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { data, response, err in
            print("Entered the completionHandler")
            
            if let error = err {
                DispatchQueue.main.sync {
                    print("error: \(error)")
                    completion(Result.error(error))
                }
                return
            }
            
            guard
            let data = data
            else {
                DispatchQueue.main.sync {
                    print("Error. Response:\n \(response as! HTTPURLResponse)")
                    completion(Result.error(Authorization.Error.unknownAPIResponse))
                }
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String] {
                videoUrls = json
                DispatchQueue.main.sync {
                    print(videoUrls)
                    completion(Result.results(videoUrls))
                }
            } else {
                DispatchQueue.main.sync {
                    print("JSON Error")
                    completion(Result.error(Authorization.Error.unknownAPIResponse))
                }
                return
            }
        }
        task.resume()

        
    }
    
    //MARK:- Upload Video to Server
    static func uploadVideo(url videoPath: URL?, completion: @escaping (Result<String>) -> Void) {
        if videoPath == nil {
            print("Error taking video path")
            completion(Result.error(Authorization.Error.urlError))
            return
        }
        
        let serverPath = "\(domain)/api/video/upload"
        guard let url = URL(string: serverPath) else {
            return
        }
        var request = URLRequest(url: url)
        
        /*
        let boundary = "------------------------my_boundary"

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(authKey, forHTTPHeaderField: "Authorization")
        
        var movieData: Data?
        do {
            movieData = try Data(contentsOf: videoPath!)
        } catch _ {
            movieData = nil
            print("Error catching video Data")
            completion(Result.error(Authorization.Error.generic))
            return
        }

        var body = Data()
        
        // setting the file name
        let filename = "upload.mov"
        let mimetype = "video/mov"

        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(movieData!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
 */
        
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(authKey, forHTTPHeaderField: "Authorization")
        //request.setValue(file.lastPathComponent, forHTTPHeaderField: "filename")
        
        print(request.allHTTPHeaderFields)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.isDiscretionary = false
        sessionConfig.networkServiceType = .video
        let session = URLSession(configuration: sessionConfig)

        let task = session.uploadTask(with: request, fromFile: videoPath!) { (data, response, error) in
            if let `error` = error {
                print(error)
                completion(Result.error(error))
                return
            }
            if let `data` = data {
                print(String(data: data, encoding: String.Encoding.utf8)!)
            }
            
            let response = response as! HTTPURLResponse
            switch response.statusCode {
            case 200:
                DispatchQueue.main.async {
                    completion(Result.results("success"))
                }
            case 400:
                DispatchQueue.main.async {
                    completion(Result.error(Authorization.Error.notAllPartsFound))
                }
                return
            case 401:
                DispatchQueue.main.async {
                    completion(Result.error(Authorization.Error.unauthorized))
                }
                return
            case 500:
                DispatchQueue.main.async {
                    print("Code 500:")
                    completion(Result.error(Authorization.Error.serverError))
                }
                return
            default:
                DispatchQueue.main.async {
                    completion(Result.error(Authorization.Error.unknownAPIResponse))
                }
                return
            }

        }
        task.resume()
    }
}

/*Second Way of uploading video with upload task
 var request = URLRequest(url: "my_url")
 request.httpMethod = "POST"
 request.setValue(file.lastPathComponent, forHTTPHeaderField: "filename")


 let sessionConfig = URLSessionConfiguration.background(withIdentifier: "it.example.upload")
 sessionConfig.isDiscretionary = false
 sessionConfig.networkServiceType = .video
 let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)

 let task = session.uploadTask(with: request, fromFile: file)
 task.resume()
 */
