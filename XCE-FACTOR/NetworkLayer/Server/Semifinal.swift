//
//  Semifinal.swift
//  XCE-FACTOR
//
//  Created by user on 20.09.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public struct likesBody: Codable {
    var battleId: Int
    var semifinalistId: Int
    init(battleId: Int, semifinalistId: Int){
        self.battleId = battleId
        self.semifinalistId = semifinalistId
    }
}
enum setOrCancelSwitch {
    case cancel
    case set
}

public class Semifinal {
    
    static var apiPath: String = "/api/semifinal/battles/get"
    static var likesPath: String = "/api/semifinal/vote"
    static var cancelLikesPath: String = "/api/semifinal/vote/cancel"
    
    static func getBattlesData(completion: @escaping (SessionResult<[Battle]>) -> Void) {
        var urlComponent = Globals.baseUrlComponent
        urlComponent.path = apiPath
        urlComponent.queryItems = nil
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
            
            guard let battleData: [Battle] = try? JSONDecoder().decode([Battle].self, from: data)//,
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
                completion(.results(battleData))
            }
        }
        task.resume()
        
    }
    
    
    static func setOrCancelLikeOf(battleId: Int, semifinalistId: Int, typeOfRequest: setOrCancelSwitch, completion: @escaping (SessionResult<Int>) -> Void) {
        var urlComponent = Globals.baseUrlComponent
        switch typeOfRequest {
            case .set:
                urlComponent.path = likesPath
            case .cancel:
                urlComponent.path = cancelLikesPath
        }
        guard let url = urlComponent.url else {
            print("Error: incorrect URL for request")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let jsonEncoded = try? JSONEncoder().encode(
            likesBody(
                battleId: battleId,
                semifinalistId: semifinalistId
            )
        ) else {
            print("JSONEncoder error while trying to set like")
            return
        }
        request.httpBody = jsonEncoded
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(.local(error)))
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            DispatchQueue.main.async {
                switch typeOfRequest {
                    case .set:
                        print("\n>>>>> Response Status Code of trying to set like in semifinal: \(response.statusCode)")
                    case .cancel:
                        urlComponent.path = cancelLikesPath
                        print("\n>>>>> Response Status Code of trying to cancel  like in semifinal: \(response.statusCode)")
                }
                
                completion(.results(response.statusCode))
            }
            return

        }.resume()
        
    }

//    static func cancelLikeOf(battleId: Int, semifinalistId: Int, completion: @escaping (SessionResult<Int>) -> Void) {
//        var urlComponent = Globals.baseUrlComponent
//        urlComponent.path = cancelLikesPath
//        guard let url = urlComponent.url else {
//            print("Error: incorrect URL for request")
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        guard let jsonEncoded = try? JSONEncoder().encode(
//            likesBody(
//                battleId: battleId,
//                semifinalistId: semifinalistId
//            )
//        ) else {
//            print("JSONEncoder error while trying to cancel like")
//            return
//        }
//        request.httpBody = jsonEncoded
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
//        print(request)
//        print(request.allHTTPHeaderFields ?? "Error: no headers")
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                DispatchQueue.main.async {
//                    completion(.error(.local(error)))
//                }
//                return
//            }
//
//            let response = response as! HTTPURLResponse
//            DispatchQueue.main.async {
//                print("\n>>>>> Response Status Code of cancelling like in semifinal: \(response.statusCode)")
//                completion(.results(response.statusCode))
//            }
//            return
//
//        }.resume()
//
//    }
}
