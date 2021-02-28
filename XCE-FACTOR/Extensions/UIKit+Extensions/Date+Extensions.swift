//
//  Date+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 27.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import Foundation

extension Date {
    func add(type: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: type, value: value, to: self) ?? Date()
    }
}

