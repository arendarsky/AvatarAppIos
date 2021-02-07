//
//  Semifinal.swift
//  XCE-FACTOR
//
//  Created by Sergey Desenko on 20.09.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public struct likesBody: Codable {

    var battleId: Int
    var semifinalistId: Int

    init(battleId: Int, semifinalistId: Int) {
        self.battleId = battleId
        self.semifinalistId = semifinalistId
    }
}

enum setOrCancelSwitch {
    case cancel
    case set
}

public class Semifinal {
    
    static var likesPath: String = "/api/semifinal/vote"
    static var cancelLikesPath: String = "/api/semifinal/vote/cancel"
    
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
