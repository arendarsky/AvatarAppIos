//
//  Result.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

enum Result<ResultType> {
    case error(Error)
    case results(ResultType)
}
