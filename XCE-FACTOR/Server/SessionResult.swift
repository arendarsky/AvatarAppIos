//
//  SessionResult.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

enum SessionResult<ResultType> {
    case error(SessionError)
    case results(ResultType)
}
