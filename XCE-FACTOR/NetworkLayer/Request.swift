//
//  Request.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 22.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

typealias Parameters = [String: Any]

enum HTTPRequestType {
    case `default`
    case bodyParameters(_ parameters: Parameters)
    case urlParameters(_ parameters: [String: String])
    case bothParameters(bodyParameters: Parameters, urlParameters: [String: String])
}

protocol RequestProtocol {
//    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var type: HTTPRequestType { get }
    var headers: [String: String] { get }
}

final class Request<Response: Decodable>: RequestProtocol {

//    let baseURL: URL

    let path: String

    let httpMethod: HTTPMethod

    let type: HTTPRequestType
    
    let headers: [String: String]

    init(path: String,
         type: HTTPRequestType = .default,
         httpMethod: HTTPMethod = .get,
         headers: [String: String] = [:]) {
        self.path = path
        self.httpMethod = httpMethod
        self.type = type
        self.headers = headers
    }
}
