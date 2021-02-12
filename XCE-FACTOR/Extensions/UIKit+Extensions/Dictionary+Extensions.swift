//
//  Dictionary+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 11.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

extension Dictionary where Value: Equatable {
    func findKey(for value: Value) -> Key? {
        return first { $1 == value }?.key
    }
}
