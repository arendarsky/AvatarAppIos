//
//  NameService.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 07.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

/// Протокол сервиса для получения и отправки фотографии пользователя
protocol NameServiceProtocol {
    
    typealias Completion = (ResultDefault) -> Void
    
    /// Сменить пароль пользователя
    func set(name: String, completion: @escaping Completion)
}

/// Сервис для смены пароля пользователя
final class NameService: NameServiceProtocol {

    // MARK: - Private Properties
    
    private let networkClient: NetworkClientProtocol
    private let basePath: String
    
    private struct Path {
        static let setName = "set_name"
    }

    /// Ключи передаваемого параметра
    enum ParametersKeys: String {
        case name
    }

    // MARK: - Init

    init(networkClient: NetworkClientProtocol, basePath: String) {
        self.networkClient = networkClient
        self.basePath = basePath
    }

    // MARK: - Public Methods

    func set(name: String, completion: @escaping Completion) {
        let headers = ["Authorization": Globals.user.token]
        let parameters = [ParametersKeys.name.rawValue: name]
        let request = Request<String>(path: basePath + "/" + Path.setName,
                                      type: .urlParameters(parameters, encodeType: .urlQueryAllowed),
                                      headers: headers)
        networkClient.sendRequest(request: request) { result in
            switch result {
            case .success(let response):
                guard response is String else {
                    completion(.failure(.default))
                    return
                }
                completion(.success)
            case .failure(let error):
                guard let error = error as? NetworkErrors else {
                    completion(.failure(.default))
                    return
                }
                completion(.failure(error))
            }
        }
    }
}

//static func setNewName(newName: String, completion: @escaping (SessionResult<Int>) -> Void) {
//        var nameComponents = Globals.baseUrlComponent
//        nameComponents.path = "/api/profile/set_name"
//        nameComponents.queryItems = [URLQueryItem(name: "name", value: newName)]
//        guard let url = nameComponents.url else {
//            print("Error: incorrect URL for request")
//            return
//        }
//
//        var request = URLRequest(url: url)
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
//                print("\n>>>>> Response Status Code of setting new Name request: \(response.statusCode)")
//                completion(.results(response.statusCode))
//            }
//            return
//
//        }.resume()
//    }
