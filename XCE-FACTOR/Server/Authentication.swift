//
//MARK:  Authentication.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import Alamofire

public class Authentication {
    
//MARK:- Send e-mail to the server
    ///This function is not used now and its syntax was not updated for a long time, so it  might be strange and/or wrong
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
    ///This function is not used now and its syntax was not updated for a long time, so it  might be strange and/or wrong
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
        guard let jsonEncoded = try? JSONEncoder().encode(
            UserAuthData(
                name: name,
                email: email,
                password: password
            )
        )
        else {
            DispatchQueue.main.async {
                print("Error encoding user data")
                completion(Result.error(SessionError.notAllPartsFound))
            }
            return
        }
        
        let serverPath = "\(Globals.domain)/api/auth/register"
        let url = URL(string: serverPath)!
        print(serverPath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonEncoded
        
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
                DispatchQueue.main.async {
                    print("Starus code: \(response.statusCode)")
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
    static func authorize(email: String, password: String, completion: @escaping (Result<Bool>) -> Void) {
        
        let serverPath = "\(Globals.domain)/api/auth/authorize?email=\(email)&password=\(password)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: serverPath)!
        print(serverPath)
        
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
            guard response.statusCode == 200,
                let data = data,
                let authData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
            else {
                DispatchQueue.main.async {
                    print("Error getting data. Response code: \(response.statusCode)")
                    completion(.error(.serverError))
                }
                return
            }
            
            guard let isConfirmationRequired: Bool = authData["confirmationRequired"] as? Bool else {
                print("Response Data Type Error. Response code: \(response.statusCode)")
                return
            }
            if isConfirmationRequired {
                DispatchQueue.main.async {
                    print("Error: User email is not confirmed")
                    completion(.error(.unconfirmed))
                }
                return
            }
            
            guard let token = authData["token"], !(token is NSNull) else {
                DispatchQueue.main.async {
                    print("Wrong email or password")
                    completion(.error(.wrongInput))
                }
                return
            }
            
            DispatchQueue.main.async {
                print("   success with token \(token as! String)")
                //MARK:- Saving to Globals and Defaults
                Globals.user.token = "Bearer \(token as! String)"
                Globals.user.email = email
                Defaults.save(token: Globals.user.token, email: Globals.user.email)
                completion(Result.results(true))
            }
            return
            
        }.resume()
        
    }
    
    
    //MARK:- Reset Password Request
    static func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        let serverPath = "\(Globals.domain)/api/auth/send_reset?email=\(email)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        let request = URLRequest(url: serverUrl!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error:", error)
                    completion(false)
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            DispatchQueue.main.async {
                completion(response.statusCode == 200)
                print("\n>>>>> Response Status Code of Resetting password request: \(response.statusCode)")
            }
            return

        }.resume()

    }
    
    //MARK:- Set Notifications Token
    static func setNotificationsToken(token: String) {
        guard let json = try? JSONSerialization.data(withJSONObject: token, options: [.fragmentsAllowed]) else {
            print("JSON Error")
            return
        }
        
        var urlComponents = Globals.baseUrlComponent
        urlComponents.path = "/api/auth/firebase_set"
        guard let url = urlComponents.url else {
            print("URL Error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = json
        print(request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            let response = response as! HTTPURLResponse
            guard let _ = data, response.statusCode == 200 else {
                print("Error Setting Notifications Token. Response status code: \(response.statusCode)")
                return
            }
            print("\n>>>> FCM Token is sent to the server successfully\n")
            
        }.resume()
    }
    
    
    //MARK:- Get User Token From JSON Data
    ///is used when only 'token' field is needed from all json data
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
            print("Error 500: server error")
            return Result.error(SessionError.serverError)
        default:
            print("Response Status Code:", response.statusCode)
            return Result.error(SessionError.unknownAPIResponse)
        }
    }
    
}
