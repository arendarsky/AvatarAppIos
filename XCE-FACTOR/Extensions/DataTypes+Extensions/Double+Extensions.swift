//
//  Double+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

extension Double {
    func rounded(places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        return (self * multiplier).rounded(.toNearestOrEven) / multiplier
    }
}
