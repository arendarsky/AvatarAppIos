//
//MARK:  Profile.swift
//  AvatarAppIos
//
//  Created by Владислав on 16.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import Alamofire

public class Profile {
    //MARK:- Ger Profile Data
    static func getData(id: Int?, completion: @escaping (Result<UserProfile>) -> Void) {
        var serverPath = "\(Globals.domain)/api/profile/get"
        if let id = id {
            serverPath = "\(Globals.domain)/api/profile/public/get?id=\(id)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        let serverUrl = URL(string: serverPath)!
        
        var request = URLRequest(url: serverUrl)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        let profileDataSession = URLSession(configuration: sessionConfig)
        
        let task = profileDataSession.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.sync {
                    print("error: \(error)")
                    completion(.error(.local(error)))
                }
                return
            }
            
            guard
                let data = data,
                let profileData: UserProfile = try? JSONDecoder().decode(UserProfile.self, from: data)
            else {
                DispatchQueue.main.sync {
                    print("Getting Data Error. Response:\n \(response as! HTTPURLResponse)")
                    completion(Result.error(SessionError.unknownAPIResponse))
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
    static func getNotifications(number: Int, skip: Int, completion: @escaping (Result<[Notification]>) -> Void) {
        let serverPath = "\(Globals.domain)/api/profile/notifications?number=\(number)&skip=\(skip)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)!
        
        var request = URLRequest(url: serverUrl)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.sync {
                    print("Error: \(error)")
                    completion(.error(.local(error)))
                }
                return
            }
            
            guard
                let data = data,
                let usersData: [Notification] = try? JSONDecoder().decode([Notification].self, from: data)
            else {
                DispatchQueue.main.sync {
                    print("Error Getting Data. Response:\n \(response as! HTTPURLResponse)")
                    completion(Result.error(SessionError.unknownAPIResponse))
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
        let serverPath = "\(Globals.domain)/api/profile/photo/get/\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)!
        
        var request = URLRequest(url: serverUrl)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { data, response, err in
            
            if let error = err {
                DispatchQueue.main.sync {
                    print("Error: \(error)")
                    completion(.error(.local(error)))
                }
                return
            }
            
            guard
                let data = data
            else {
                DispatchQueue.main.sync {
                    print("Error getting data. Response:\n \(response as! HTTPURLResponse)")
                    completion(Result.error(SessionError.unknownAPIResponse))
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
    static func setDescription(newDescription: String, completion: @escaping (Result<Int>) -> Void) {
        let serverPath = "\(Globals.domain)/api/profile/set_description?description=\(newDescription)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.httpMethod = "POST"
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        print(request)
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
                print("\n>>>>> Response Status Code of setting new description request: \(response.statusCode)")
                completion(Result.results(response.statusCode))
            }
            return

        }.resume()
    }
    
    //MARK:- Change Password
    static func changePassword(oldPassword: String, newPassword: String, completion: @escaping (Result<Bool>) -> Void) {
        let serverPath = "\(Globals.domain)/api/profile/set_password?oldPassword=\(oldPassword)&newPassword=\(newPassword)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.httpMethod = "POST"
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        print(request)
        print(request.allHTTPHeaderFields ?? "Error: no headers")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.error(.local(error)))
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            print("\n>>>>> Response Status Code of setting new password request: \(response.statusCode)")

            guard let data = data else {
                DispatchQueue.main.async {
                    print("Data Error")
                    completion(Result.error(SessionError.serverError))
                }
                return
            }
            
            guard let isCorrect = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                DispatchQueue.main.async {
                    print("JSON Error")
                    completion(Result.error(SessionError.serverError))
                }
                return
            }
            
            DispatchQueue.main.async {
                print("Is old passowrd correct: \(isCorrect)")
                completion(Result.results(isCorrect as? Bool ?? false))
            }
            return

        }.resume()
    }
    
    //MARK:- Set New Name
    static func setNewName(newName: String, completion: @escaping (Result<Int>) -> Void) {
        let serverPath = "\(Globals.domain)/api/profile/set_name?name=\(newName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let serverUrl = URL(string: serverPath)
        
        var request = URLRequest(url: serverUrl!)
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        print(request)
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
                print("\n>>>>> Response Status Code of setting new Name request: \(response.statusCode)")
                completion(Result.results(response.statusCode))
            }
            return

        }.resume()
    }
    
    
    //MARK:- Set New Image
    static func setNewImage(image: UIImage?, completion: @escaping (Result<Int>) -> Void) {
        guard let image = image,
            let imageData = image.jpegData(compressionQuality: 0.25)
        else { return }
        
        let serverPath = "\(Globals.domain)/api/profile/photo/upload"
        let headers: HTTPHeaders = [
            "Authorization": "\(Globals.user.token)"
        ]
        
        AF.upload(multipartFormData: { (data) in
            data.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
        }, to: serverPath, headers: headers)
            .response { response in
                switch response.result {
                case .success:
                    print("Alamofire session success")
                    let statusCode = response.response!.statusCode
                    print("upload request status code:", statusCode)
                    
                    DispatchQueue.main.async {
                        completion(.results(statusCode))
                    }
                    return
                    
                case .failure(let error):
                    print("Alamofire session failure. Error: \(error)")
                    
                    DispatchQueue.main.async {
                        completion(.error(.serverError))
                    }
                    return
                }
        }
    }
    
}
