//
//  WebVideo.swift
//  AvatarAppIos
//
//  Created by Владислав on 07.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Alamofire

public class WebVideo {

    //MARK:- Get Video Names w/ User Info
    static func getUnwatched(completion: @escaping (Result<[CastingVideo]>) -> Void) {
        //let numberOfVideos = 100
        let serverPath = "\(domain)/api/video/get_unwatched?number=\(100)"
        let serverUrl = URL(string: serverPath)!
        var request = URLRequest(url: serverUrl)

        //request.setValue("text/plain", forHTTPHeaderField: "accept")
        request.setValue(user.token, forHTTPHeaderField: "Authorization")

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { data, response, err in
            //print("Received videos:")
            
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
                    completion(Result.error(Authentication.Error.unknownAPIResponse))
                }
                return
            }
            
            guard
                let users: [CastingVideo] = try? JSONDecoder().decode([CastingVideo].self, from: data)
            else {
                DispatchQueue.main.sync {
                    print("response code:", (response as! HTTPURLResponse).statusCode)
                    print("JSON Error")
                    //completion(Result.error(Authentication.Error.unknownAPIResponse))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(Result.results(users))
            }
        }
        task.resume()

        
    }
    
    //MARK:- Set Like / Dislike
    static func setLike(videoName: String, isLike: Bool = true, completion: @escaping (Bool) -> Void) {
        let serverPath = "\(domain)/api/video/set_like?name=\(videoName)&isLike=\(isLike)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        var request = URLRequest(url: serverUrl!)
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error:", error)
                    completion(false)
                    return
                }
            }
            
            let response = response as! HTTPURLResponse
            DispatchQueue.main.async {
                completion(response.statusCode == 200)
                print("\n>>>>> Response Status Code of setting \(isLike ? "like" : "dislike") request: \(response.statusCode)")
            }
            return

        }.resume()

    }
    
    
    //MARK:- Set Interval
    static func setInterval(videoName: String, startTime: Double, endTime: Double, completion: @escaping (Result<Int>) -> Void) {
        let msStartTime = 1000 * startTime
        let msEndTime = 1000 * endTime
        let serverPath = "\(domain)/api/video/set_interval?fileName=\(videoName)&startTime=\(msStartTime)&endTime=\(msEndTime)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                    return
                }
            }
            
            let response = response as! HTTPURLResponse
            DispatchQueue.main.async {
                print("\n>>>>> Response Status Code of setting video interval request: \(response.statusCode)")
                completion(Result.results(response.statusCode))
            }
            return

        }.resume()
    }
    
    //MARK:- Set Video Active in Casting
    static func setActive(videoName: String, completion: @escaping (Bool) -> Void) {
        let serverPath = "\(domain)/api/video/set_active?fileName=\(videoName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    completion(false)
                    return
                }
            }
            
            let response = response as! HTTPURLResponse
            DispatchQueue.main.async {
                print("\n>>>>> Response Status Code of setting video active request: \(response.statusCode)")
                completion(response.statusCode == 200)
            }
            return

        }.resume()
    }
    
    //MARK:- Delete Video
    static func delete(videoName: String, completion: @escaping (Bool) -> Void) {
        let serverPath = "\(domain)/api/video/remove/\(videoName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    completion(false)
                    return
                }
            }
            
            let response = response as! HTTPURLResponse
            DispatchQueue.main.async {
                print("\n>>>>> Response Status Code of deletting video request: \(response.statusCode)")
                completion(response.statusCode == 200)
            }
            return

        }.resume()
    }
    
    
    //MARK:- Upload Video to Server
    static func uploadVideo(url videoPath: URL?, completion: @escaping (Result<String>) -> Void) {
        if videoPath == nil {
            print("Error taking video path")
            completion(Result.error(Authentication.Error.urlError))
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
            completion(Result.error(Authentication.Error.generic))
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
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        //request.setValue(file.lastPathComponent, forHTTPHeaderField: "filename")
        
        print(request.allHTTPHeaderFields ?? "no headers")
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
                    completion(Result.error(Authentication.Error.notAllPartsFound))
                }
                return
            case 401:
                DispatchQueue.main.async {
                    completion(Result.error(Authentication.Error.unauthorized))
                }
                return
            case 500:
                DispatchQueue.main.async {
                    print("Code 500:")
                    completion(Result.error(Authentication.Error.serverError))
                }
                return
            default:
                DispatchQueue.main.async {
                    completion(Result.error(Authentication.Error.unknownAPIResponse))
                }
                return
            }

        }
        task.resume()
    }
}
