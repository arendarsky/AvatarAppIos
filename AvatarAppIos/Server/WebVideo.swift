//
//  WebVideo.swift
//  AvatarAppIos
//
//  Created by Владислав on 07.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import Alamofire

public class WebVideo {

    //MARK:- Get Video Names w/ User Info
    static func getUnwatched(numberOfVideos: Int = 10, completion: @escaping (Result<[CastingVideo]>) -> Void) {
        //let numberOfVideos = 100
        let serverPath = "\(Globals.domain)/api/video/get_unwatched?number=\(numberOfVideos)"
        let serverUrl = URL(string: serverPath)!
        var request = URLRequest(url: serverUrl)

        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { data, response, err in
            //print("Received videos:")
            
            if let error = err {
                DispatchQueue.main.sync {
                    print("error: \(error)")
                    completion(.error(.local(error)))
                }
                return
            }
            
            guard
                let data = data
            else {
                DispatchQueue.main.sync {
                    print("Error. Response:\n \(response as! HTTPURLResponse)")
                    completion(Result.error(SessionError.unknownAPIResponse))
                }
                return
            }
            
            guard
                let users: [CastingVideo] = try? JSONDecoder().decode([CastingVideo].self, from: data)
            else {
                DispatchQueue.main.sync {
                    print("response code:", (response as! HTTPURLResponse).statusCode)
                    print("JSON Error")
                    completion(.error(.serverError))
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
        let serverPath = "\(Globals.domain)/api/video/set_like?name=\(videoName)&isLike=\(isLike)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        var request = URLRequest(url: serverUrl!)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error:", error)
                    completion(false)
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            DispatchQueue.main.async {
                completion(true)
                //MARK:- ❗️Ignoring All Server Errors Now
                //completion(response.statusCode == 200)
                print("\n>>>>> Response Status Code of setting \(isLike ? "like" : "dislike") request: \(response.statusCode)")
            }
            return

        }.resume()

    }
    
    
    //MARK:- Set Interval
    static func setInterval(videoName: String, startTime: Double, endTime: Double, completion: @escaping (Bool) -> Void) {
        let msStartTime = 1000 * startTime
        let msEndTime = 1000 * endTime
        let serverPath = "\(Globals.domain)/api/video/set_interval?fileName=\(videoName)&startTime=\(msStartTime)&endTime=\(msEndTime)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error setting interval: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            DispatchQueue.main.async {
                print("\n>>>>> Response Status Code of setting video interval request: \(response.statusCode)")
                completion(response.statusCode == 200)
            }
            return

        }.resume()
    }
    
    //MARK:- Set Video Active in Casting
    static func setActive(videoName: String, completion: @escaping (Bool) -> Void) {
        let serverPath = "\(Globals.domain)/api/video/set_active?fileName=\(videoName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 10
        let setActiveSession = URLSession(configuration: cfg)
        
        setActiveSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    completion(false)
                }
                return
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
        let serverPath = "\(Globals.domain)/api/video/remove/\(videoName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    completion(false)
                }
                return
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
    static func uploadVideo(url videoPath: URL?, uploadProgress: ((Float) -> Void)?, completion: @escaping (Result<String?>) -> Void) {
        guard let videoUrl = videoPath else {
            print("Error taking video path")
            completion(Result.error(SessionError.urlError))
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "\(Globals.user.token)"
        ]
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(videoUrl, withName: "file", fileName: "file.mp4", mimeType: "video/mp4")
        }, to: "\(Globals.domain)/api/video/upload", headers: headers)
            
            .uploadProgress { (progress) in
                print(">>>> Upload progress: \(Int(progress.fractionCompleted * 100))%")
                uploadProgress?(Float(progress.fractionCompleted))
            }
            
            .response { (response) in
                print(response.request!)
                print(response.request!.allHTTPHeaderFields!)
                
                switch response.result {
                case .success:
                    print("Alamofire session success")
                    print("upload request status code:", response.response!.statusCode)
                    if response.response!.statusCode != 200 {
                        DispatchQueue.main.async {
                            completion(.error(.serverError))
                        }
                        return
                    }
                case .failure(let error):
                    print("Alamofire session failure")
                    let alternativeTimeOutCode = 13
                    var sessionError = SessionError.serverError
                    if error._code == NSURLErrorTimedOut || error._code == alternativeTimeOutCode {
                        sessionError = .requestTimedOut
                    }
                    DispatchQueue.main.async {
                        completion(.error(sessionError))
                    }
                    return
                }
                
                //MARK:- From this point video is successfully uploaded to the server
                //the only thing left is to get video name from the server response

                if let data = response.data, let videoInfo = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                        DispatchQueue.main.async {
                            completion(.results(videoInfo as? String))
                        }
                        return
                } else {
                    DispatchQueue.main.async {
                        completion(.results(nil))
                    }
                    return
                }
        }
    }
}
