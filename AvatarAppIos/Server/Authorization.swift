//
//  Authorization.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

public class Authorization {
    
    enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
        case notAllPartsFound
        case urlError
    }
    
//MARK:- Send e-mail to the server
    static func sendEmail(email: String, completion: @escaping (Result<String>) -> Void) {
        let serverPath = "https://avatarappapi20200123093213.azurewebsites.net/api/auth/send?email=\(email)"
        print(serverPath)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        let emailSession = URLSession(configuration: config)
        
        emailSession.dataTask(with: URL(string: serverPath)!) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            } else {
                DispatchQueue.main.async {
                    completion(Result.results("success"))
                }
                return
            }
        }.resume()
    }
    
//MARK:- Check confirmation code
    static func confirmCode(email: String, code: String, completion: @escaping (Result<String>) -> Void) {
        let serverPath = "https://avatarappapi20200123093213.azurewebsites.net/api/auth/confirm?email=\(email)&confirmCode=\(code)"
        print(serverPath)
        //let apiKey = "517c0511-c38e-4039-8c7a-5f5ed58cb2ae"
        
        URLSession.shared.dataTask(with: URL(string: serverPath)!) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            
            guard
            let _ = response as? HTTPURLResponse,
            let data = data
            else {
                DispatchQueue.main.async {
                    completion(Result.error(Error.unknownAPIResponse))
                }
                return
            }
            
            do {
                guard
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
                else {
                    DispatchQueue.main.async {
                        completion(Result.error(Error.unknownAPIResponse))
                    }
                    return
                }
                print("json file: \(json)")
                
                print("Confirmation code check result:")
                if let answer = json["session_guid"] {
                    if !(answer is NSNull) {
                        DispatchQueue.main.async {
                            print("   success with answer \(answer)")
                            completion(Result.results("success"))
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            print("fail")
                            completion(Result.results("fail"))
                        }
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        print("fail")
                        completion(Result.results("fail"))
                    }
                    return
                }
                
            } catch {
                completion(Result.error(error))
                return
            }
        }.resume()
    }
}
