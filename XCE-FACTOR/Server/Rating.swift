//
//MARK:  Rating.swift
//  AvatarAppIos
//
//  Created by Владислав on 10.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public class Rating {
    //MARK:- Rating Data
    enum RatingData {
        case topList, semifinalists
        
        var apiPath: String {
            switch self {
            case .topList:
                return "/api/rating/get"
            case .semifinalists:
                return "/api/rating/get_semifinalists"
            }
        }
        
        func setQueryItems() -> [URLQueryItem]? {
            switch self {
            case .topList:
                let numberOfItems: Int = 200
                return [URLQueryItem(name: "number", value: "\(numberOfItems)")]
            
            case .semifinalists:
                return nil
            }
        }
    }
    
    //MARK:- Get Rating Data
    static func getRatingData(ofType dataType: RatingData, completion: @escaping (SessionResult<[RatingProfile]>) -> Void) {
        var urlComponent = Globals.baseUrlComponent
        urlComponent.path = dataType.apiPath
        urlComponent.queryItems = dataType.setQueryItems()
        guard let url = urlComponent.url else {
            print("URL Error")
            return
        }
        
        var request = URLRequest(url: url)
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
            
            guard let data = data else {
                DispatchQueue.main.sync {
                    print("Error. Response:\n \(response as! HTTPURLResponse)")
                    completion(.error(.unknownAPIResponse))
                }
                return
            }
            
            guard let ratingData: [RatingProfile] = try? JSONDecoder().decode([RatingProfile].self, from: data)//,
                //let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            else {
                DispatchQueue.main.sync {
                    print("response code:", (response as! HTTPURLResponse).statusCode)
                    print("JSON Error")
                    completion(.error(.serverError))
                }
                return
            }
            
            //if dataType == .semifinalists {
           //     print(json)
            //}
            
            DispatchQueue.main.async {
                completion(.results(ratingData))
            }
        }
        task.resume()
        
    }
}
