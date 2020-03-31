//
//  Authentication.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import Alamofire

public class Authentication {
    
//MARK:- Send e-mail to the server
    static func sendEmail(email: String, completion: @escaping (Result<String>) -> Void) {
        let serverPath = "\(Globals.domain)/api/auth/send?email=\(email)"
        print(serverPath)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        let emailSession = URLSession(configuration: config)
        
        emailSession.dataTask(with: URL(string: serverPath)!) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(.local(error)))
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            if response.statusCode == 500 {
                DispatchQueue.main.async {
                    completion(.error(.serverError))
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
        let serverPath = "\(Globals.domain)/api/auth/confirm?email=\(email)&confirmCode=\(code)"
        print(serverPath)
        
        URLSession.shared.dataTask(with: URL(string: serverPath)!) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(.local(error)))
                }
                return
            }
            
            guard
                let _ = response as? HTTPURLResponse,
                let data = data
            else {
                DispatchQueue.main.async {
                    completion(Result.error(.unknownAPIResponse))
                }
                return
            }
            
            if let token = getTokenFromJSONData(data) {
                DispatchQueue.main.async {
                    print("   success with token \(token)")
                    Globals.user.token = "Bearer \(token)"
                    completion(Result.results("success"))
                }
                return
            }
            else {
                DispatchQueue.main.async {
                    print("fail. token is nil")
                    completion(Result.results("fail"))
                }
                return
            }
            
        }.resume()
    }
    
    
    //MARK:- Register New User
    static func registerNewUser(name: String, email: String, password: String, completion: @escaping (Result<Bool>) -> Void) {
        
        let serverPath = "\(Globals.domain)/api/auth/register"
        let url = URL(string: serverPath)!
        print(serverPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let jsonEncoded = try? JSONEncoder().encode(
            UserAuthData(
                name: name,
                email: email,
                password: password
            )
        )
        else {
            DispatchQueue.main.async {
                debugPrint("Error encoding user data")
                completion(Result.error(SessionError.notAllPartsFound))
            }
            return
        }
        
        
        request.httpBody = jsonEncoded
        //print("body:", request.httpBody! as Any)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        let registerSession = URLSession(configuration: config)
        
        registerSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(.local(error)))
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            if response.statusCode != 200 {
                //let result = handleHttpResponse(response)
                DispatchQueue.main.async {
                    completion(Result.error(SessionError.serverError))
                }
                return
            }
            
            
            if let data = data {
                if let isNewUser = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                    DispatchQueue.main.async {
                        print(isNewUser)
                        completion(Result.results(isNewUser as! Bool))
                    }
                } else {
                    print("some trouble with data")
                }
            }
            
            
        }.resume()
        
    }
    
    
    //MARK:- Authorize
    static func authorize(email: String, password: String, completion: @escaping (Result<String>) -> Void) {
        
        let serverPath = "\(Globals.domain)/api/auth/authorize?email=\(email)&password=\(password)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: serverPath)!
        
        debugPrint(serverPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        let authSession = URLSession(configuration: config)
        
        authSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(.local(error)))
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            if response.statusCode != 200 {
                let result = handleHttpResponse(response)
                DispatchQueue.main.async {
                    completion(result)
                }
                return
            }
            
            if let data = data {
                guard let token = getTokenFromJSONData(data) else {
                    DispatchQueue.main.async {
                        print("Wrong email or password")
                        completion(Result.error(SessionError.unauthorized))
                    }
                    return
                }
                if token != "jsonError" {
                    DispatchQueue.main.async {
                        print("   success with token \(token)")
                        Globals.user.token = "Bearer \(token)"
                        Globals.user.email = email
                        
                        //MARK:- Saving to Defaults
                        Defaults.save(token: Globals.user.token, email: Globals.user.email)
                        completion(Result.results("success"))
                    }
                    return
                    
                } else {
                    DispatchQueue.main.async {
                        print("Error JSON Serialization")
                        completion(Result.error(SessionError.serverError))
                    }
                    return
                }
                
            } else {
                DispatchQueue.main.async {
                    print("Error unwrapping data")
                    completion(Result.error(SessionError.serverError))
                }
                return
            }
            

        }.resume()
        
    }
    
    
    //MARK:- Get User Token From JSON Data
    static private func getTokenFromJSONData(_ data: Data) -> String? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
        else {
            print("JSON Serialization Error")
            return "jsonError"
        }
        print("json file: \(json)")
        
        print("Token result:")
        guard let answer = json["token"] else { return nil }
        
        if answer is NSNull {
            return nil
        }
        else {
            return answer as? String
        }
        
    }
    
    //MARK:- Handle HTTP Response
    private static func handleHttpResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200:
            print("Code 200")
            return Result.results("success")
        case 400:
            debugPrint("Error 400: some required fields are null")
            return Result.error(SessionError.notAllPartsFound)
        case 500:
            return Result.error(SessionError.serverError)
        default:
            print("Response Status Code:", response.statusCode)
            return Result.error(SessionError.unknownAPIResponse)
        }
    }
    
}
