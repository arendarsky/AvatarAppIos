//
//  Rating.swift
//  AvatarAppIos
//
//  Created by Владислав on 10.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public class Rating {
    //MARK:- Get Rating Data
    static func getData(completion: @escaping (Result<[UserProfile]>) -> Void) {
        let number: Int = 20
        let serverPath = "\(domain)/api/rating/get?number=\(number)"
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
                let ratingData: [UserProfile] = try? JSONDecoder().decode([UserProfile].self, from: data)
            else {
                DispatchQueue.main.sync {
                    print("response code:", (response as! HTTPURLResponse).statusCode)
                    print("JSON Error")
                    //completion(Result.error(Authentication.Error.unknownAPIResponse))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(Result.results(ratingData))
            }
        }
        task.resume()
        
    }
    
    //MARK:- Get Like Notifications
    static func getLikeNotifications(completion: @escaping (Result<[UserProfile]>) -> Void) {
        let number: Int = 20
        let serverPath = "\(domain)/api/rating/likes/get?number=\(number)&skip=\(0)"
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
                let usersData: [UserProfile] = try? JSONDecoder().decode([UserProfile].self, from: data)
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
        }
        task.resume()
    }
}
