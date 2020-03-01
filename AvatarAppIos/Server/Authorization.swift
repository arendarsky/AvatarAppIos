//
//  Authorization.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

//MARK:- Important global values for all server funcs
public let domain = "https://avatarapp.yambr.ru"
public var authKey = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjkwYmYyODQ2LTFjNzMtNDY3ZS05YjE3LThmOGYyZWI0OTlhZCIsImlzcyI6IkF2YXRhckFwcCIsImF1ZCI6IkF2YXRhckFwcENsaWVudCJ9.aRxPaYnMNOM8882Dzh23lQxaoC0jxxOfs1iSi9sG9Vk"

public class Authorization {
    
    public enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
        case notAllPartsFound
        case urlError
        case serverError
        case unauthorized
    }
    
//MARK:- Send e-mail to the server
    static func sendEmail(email: String, completion: @escaping (Result<String>) -> Void) {
        let serverPath = "\(domain)/api/auth/send?email=\(email)"
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
            }
            
            let response = response as! HTTPURLResponse
            if response.statusCode == 500 {
                DispatchQueue.main.async {
                    completion(Result.error(Error.serverError))
                }
                return
            }
            
            //in other case
                DispatchQueue.main.async {
                    completion(Result.results("success"))
                }
                return
            
        }.resume()
    }
    
//MARK:- Check confirmation code
    static func confirmCode(email: String, code: String, completion: @escaping (Result<String>) -> Void) {
        let serverPath = "\(domain)/api/auth/confirm?email=\(email)&confirmCode=\(code)"
        print(serverPath)
        
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
                if let answer = json["token"] {
                    if !(answer is NSNull) {
                        DispatchQueue.main.async {
                            print("   success with answer \(answer)")
                            authKey = "Bearer \(answer)"
                            user.token = authKey
                            completion(Result.results("success"))
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            print("fail")
                            print(answer)
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
    
    
    //MARK:- Register New User
    static func registerNewUser(name: String, email: String, password: String,  completion: @escaping (Result<String>) -> Void) {
        
        let serverPath = "\(domain)/api/auth/register"
        print(serverPath)
        
    }
    
    
    //MARK:- Authorize
    static func authorize(email: String, password: String) {
        
        let serverPath = "\(domain)/api/auth/authorize?email=\(email)?password=\(password)"
        print(serverPath)
    }
}
