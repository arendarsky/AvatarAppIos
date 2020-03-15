//
//  Profile.swift
//  AvatarAppIos
//
//  Created by Владислав on 16.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public class Profile {
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
                completion(Result.results(profileData))
            }
        }
        task.resume()
    }
}
