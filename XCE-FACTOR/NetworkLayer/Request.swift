//
//  Request.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 22.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

typealias Parameters = [String: Any]

// MARK: - Public Enums

/// Классическая ответ для комплишн блока
enum ResultDefault {
    case success
    case failure(_ error: NetworkErrors)
}

/// Типы http запросов
enum HTTPRequestType {
    case `default`
    case urlParameters(_ parameters: [String: String], encodeType: CharacterSet? = nil)
    case bodyParameter(_ parameter: Int)
    case bodyParameters(_ parameters: Parameters)
    case image(imagePath: String, encodeType: CharacterSet? = nil)
}

protocol RequestProtocol {
    //    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var type: HTTPRequestType { get }
    var headers: [String: String] { get }
    var checkStatusCode200: Bool { get }
}

final class Request<Response: Decodable>: RequestProtocol {

//    let baseURL: URL

    let path: String

    let httpMethod: HTTPMethod

    let type: HTTPRequestType
    
    let headers: [String: String]

    let checkStatusCode200: Bool

    init(path: String,
         type: HTTPRequestType = .default,
         httpMethod: HTTPMethod = .get,
         headers: [String: String] = [:],
         checkStatusCode200: Bool = false) {
        self.path = path
        self.httpMethod = httpMethod
        self.type = type
        self.headers = headers
        self.checkStatusCode200 = checkStatusCode200
    }
}
