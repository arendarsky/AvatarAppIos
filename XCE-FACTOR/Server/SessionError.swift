//
//  SessionError.swift
//  AvatarAppIos
//
//  Created by Владислав on 30.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public enum SessionError: Swift.Error {
    case local(Swift.Error)
    case unknownAPIResponse
    case notAllPartsFound
    case urlError
    case serverError
    case networkError
    case unauthorized
    case wrongInput
    case unconfirmed
    case requestTimedOut
    case invalidUrl
    case writingError
    case dataError
}
