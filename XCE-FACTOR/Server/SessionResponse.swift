//
//  SessionResponse.swift
//  XCE-FACTOR
//
//  Created by Владислав on 15.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

class SessionResponse<T: Decodable>: Decodable {
    var message: String?
    var data: T?
}
