//
//  AvatarAppIos
//
//  Created by Владислав on 16.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import Alamofire

public class Profile {
//    static func getData(id: Int?, completion: @escaping (SessionResult<UserProfile>) -> Void) {
//        var serverPath = "\(Globals.domain)/api/profile/get"
//        if let id = id {
//            serverPath = "\(Globals.domain)/api/profile/public/get?id=\(id)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        }
//        let serverUrl = URL(string: serverPath)!
//
//        var request = URLRequest(url: serverUrl)
//        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
//        print(request)
//
//        let sessionConfig = URLSessionConfiguration.default
//        let profileDataSession = URLSession(configuration: sessionConfig)
//
//        let task = profileDataSession.dataTask(with: request) { data, response, error in
//            if let error = error {
//                DispatchQueue.main.sync {
//                    print("error: \(error)")
//                    completion(.error(.local(error)))
//                }
//                return
//            }
//
//            guard
//                let data = data,
//                //let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
//                let profileData: UserProfile = try? JSONDecoder().decode(UserProfile.self, from: data)
//            else {
//                DispatchQueue.main.sync {
//                    print("Getting Data Error. Response:\n \(response as! HTTPURLResponse)")
//                    completion(.error(.unknownAPIResponse))
//                }
//                return
//            }
//            //print("\n\nReceived profile data:\n", json)
//
//            DispatchQueue.main.async {
//                print("successfully received profile data")
//                completion(.results(profileData))
//            }
//            return
//        }
//        task.resume()
//    }

//    static func getNotifications(number: Int, skip: Int, completion: @escaping (SessionResult<[Notification]>) -> Void) {
//        let serverPath = "\(Globals.domain)/api/profile/notifications?number=\(number)&skip=\(skip)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        let serverUrl = URL(string: serverPath)!
//        
//        var request = URLRequest(url: serverUrl)
//        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
//        
//        let sessionConfig = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfig)
//        
//        session.dataTask(with: request) { data, response, error in
//            if let error = error {
//                DispatchQueue.main.sync {
//                    print("Error: \(error)")
//                    completion(.error(.local(error)))
//                }
//                return
//            }
//            
//            guard
//                let data = data,
//                let usersData: [Notification] = try? JSONDecoder().decode([Notification].self, from: data)
//            else {
//                DispatchQueue.main.sync {
//                    print("Error Getting Data. Response:\n \(response as! HTTPURLResponse)")
//                    completion(.error(SessionError.unknownAPIResponse))
//                }
//                return
//            }
//
//            DispatchQueue.main.async {
//                completion(.results(usersData))
//            }
//            return
//        }.resume()
//    }
    
    
    //MARK:- Get Profile Image
    static func getProfileImage(name: String, completion: @escaping (SessionResult<UIImage?>) -> Void) {
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
            
            guard let data = data else {
                DispatchQueue.main.sync {
                    print("Error getting data. Response:\n \(response as! HTTPURLResponse)")
                    completion(.error(SessionError.unknownAPIResponse))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.results(UIImage(data: data)))
            }
            return
        }
        task.resume()
    }

//    static func setDescription(newDescription: String, completion: @escaping (SessionResult<Int>) -> Void) {
//        var descriptionComponents = Globals.baseUrlComponent
//        descriptionComponents.path = "/api/profile/set_description"
//        descriptionComponents.queryItems = [URLQueryItem(name: "description", value: newDescription)]
//        guard let url = descriptionComponents.url else {
//            print("Error: incorrect URL for request")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
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
//                print("\n>>>>> Response Status Code of setting new description request: \(response.statusCode)")
//                completion(.results(response.statusCode))
//            }
//            return
//
//        }.resume()
//    }
    
    //MARK:- Change Password
    static func changePassword(oldPassword: String, newPassword: String, completion: @escaping (SessionResult<Bool>) -> Void) {
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
                    completion(.error(.serverError))
                }
                return
            }
            
            guard let isCorrect = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                DispatchQueue.main.async {
                    print("JSON Error")
                    completion(.error(SessionError.serverError))
                }
                return
            }
            
            DispatchQueue.main.async {
                print("Is old passowrd correct: \(isCorrect)")
                completion(.results(isCorrect as? Bool ?? false))
            }
            return

        }.resume()
    }
    
    //MARK:- Set New Name
    static func setNewName(newName: String, completion: @escaping (SessionResult<Int>) -> Void) {
        var nameComponents = Globals.baseUrlComponent
        nameComponents.path = "/api/profile/set_name"
        nameComponents.queryItems = [URLQueryItem(name: "name", value: newName)]
        guard let url = nameComponents.url else {
            print("Error: incorrect URL for request")
            return
        }
        
        var request = URLRequest(url: url)
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
                completion(.results(response.statusCode))
            }
            return

        }.resume()
    }
    
    // MARK: - Set New Image

    static func setNewImage(image: UIImage?, completion: @escaping (SessionResult<Int>) -> Void) {
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
    
    //MARK:- Update Several Changes
    static func updateChanges(name: String, description: String, instagramNickname: String, completion: @escaping  ((SessionResult<Bool>) -> Void)) {
        
        guard let jsonEncoded = try? JSONEncoder().encode(
            UserProfile(
                name: name,
                description: description,
                instagramLogin: instagramNickname
            )
        )
        else {
            print("Error encoding profile data")
            completion(.error(.dataError))
            return
        }
        
        var urlComponents = Globals.baseUrlComponent
        urlComponents.path = "/api/profile/update_profile"
        guard let url = urlComponents.url else {
            print("URL components error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Globals.user.token, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonEncoded
        print(request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    completion(.error(.local(error)))
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data else {
                    DispatchQueue.main.async {
                        completion(.error(.serverError))
                    }
                return
            }
                        
            if let message = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? String {
                print(message)
                DispatchQueue.main.async {
                    completion(.results(false))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.results(true))
            }
            
        }.resume()
    }
}
