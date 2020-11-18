//
//  TimeInterval+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

enum TimeIntervalNames {
    case minute, hour, day, week, year, leapYear
    
    var seconds: Double {
        switch self {
        case .minute:
            return 60
        case .hour:
            return 60 * 60
        case .day:
            return 24 * 60 * 60
        case .week:
            return 7 * 24 * 60 * 60
        case .year:
            return 365 * 24 * 60 * 60
        case .leapYear:
            return 366 * 24 * 60 * 60
        }
    }
}

extension TimeInterval {

    /// Returns time interval in seconds for widely-used types of time
    static func secondsIn(_ time: TimeIntervalNames) -> Double {
        return time.seconds
    }
}
