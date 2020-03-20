//
//  Profile.swift
//  AvatarAppIos
//
//  Created by Владислав on 16.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import UIKit

public class Profile {
    //MARK:- Ger Profile Data
    static func getData(completion: @escaping (Result<UserProfile>) -> Void) {
        let serverPath = "\(domain)/api/profile/get"
        let serverUrl = URL(string: serverPath)!
        
        var request = URLRequest(url: serverUrl)
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { data, response, err in
            
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
                let profileData: UserProfile = try? JSONDecoder().decode(UserProfile.self, from: data)
            else {
                DispatchQueue.main.sync {
                    print("response code:", (response as! HTTPURLResponse).statusCode)
                    print("JSON Error")
                    //completion(Result.error(Authentication.Error.unknownAPIResponse))
                }
                return
            }
            
            DispatchQueue.main.async {
                print("successfully received profile data")
                completion(Result.results(profileData))
            }
            return
        }
        task.resume()
    }
    
    
    //MARK:- Get Like Notifications
    static func getNotifications(number: Int = 20, skip: Int = 0, completion: @escaping (Result<[Notification]>) -> Void) {
        let serverPath = "\(domain)/api/profile/notifications?number=\(number)&skip=\(skip)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)!
        
        var request = URLRequest(url: serverUrl)
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { data, response, err in
            
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
                let usersData: [Notification] = try? JSONDecoder().decode([Notification].self, from: data)
            else {
                DispatchQueue.main.sync {
                    print("response code:", (response as! HTTPURLResponse).statusCode)
                    print("JSON Error")
                    //completion(Result.error(Authentication.Error.unknownAPIResponse))
                }
                return
            }
            DispatchQueue.main.async {
                completion(Result.results(usersData))
            }
            return
        }
        task.resume()
    }
    
    
    //MARK:- Get Profile Image
    static func getProfileImage(name: String, completion: @escaping (Result<UIImage?>) -> Void) {
        let serverPath = "\(domain)/api/profile/photo/get/\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)!
        
        var request = URLRequest(url: serverUrl)
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { data, response, err in
            
            if let error = err {
                DispatchQueue.main.sync {
                    print("Error: \(error)")
                    completion(Result.error(error))
                }
                return
            }
            
            guard
                let data = data
            else {
                DispatchQueue.main.sync {
                    print("Error getting data. Response:\n \(response as! HTTPURLResponse)")
                    completion(Result.error(Authentication.Error.unknownAPIResponse))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(Result.results(UIImage(data: data)))
            }
            return
        }
        task.resume()
        
    }
    
    //MARK:- Set Description
    static func setDescription(description: String, completion: @escaping (Result<Int>) -> Void) {
        let serverPath = "\(domain)/api/profile/set_description?description=\(description)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.httpMethod = "POST"
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
                print("\n>>>>> Response Status Code of setting new description request: \(response.statusCode)")
                completion(Result.results(response.statusCode))
            }
            return

        }.resume()
    }
}
