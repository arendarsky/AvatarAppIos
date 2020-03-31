//
//  SessionError.swift
//  AvatarAppIos
//
//  Created by Владислав on 30.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

public enum SessionError: Swift.Error {
    case unknownAPIResponse
    case local(Swift.Error)
    case notAllPartsFound
    case urlError
    case serverError
    case unauthorized
    case wrongInput
    case unconfirmed
}
