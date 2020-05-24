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
    static func getRatingData(completion: @escaping (SessionResult<[RatingProfile]>) -> Void) {
        let number: Int = 500
        let serverPath = "\(Globals.domain)/api/rating/get?number=\(number)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)!
        
        var request = URLRequest(url: serverUrl)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { data, response, err in
            
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
                    completion(.error(SessionError.unknownAPIResponse))
                }
                return
            }
            
            guard
                let ratingData: [RatingProfile] = try? JSONDecoder().decode([RatingProfile].self, from: data)
            else {
                DispatchQueue.main.sync {
                    print("response code:", (response as! HTTPURLResponse).statusCode)
                    print("JSON Error")
                    completion(.error(.serverError))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.results(ratingData))
            }
        }
        task.resume()
        
    }
    
}
