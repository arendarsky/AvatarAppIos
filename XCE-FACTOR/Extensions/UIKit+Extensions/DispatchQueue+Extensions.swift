//
//  DispatchQueue+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

public extension DispatchQueue {
    static func background(delay: Double = 0.0,
                           background: (() -> Void)? = nil,
                           completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { completion() }
            }
        }
    }
}
