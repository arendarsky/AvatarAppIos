//
//MARK:  DataTypesExtensions.swift
//  AvatarAppIos
//
//  Created by Владислав on 08.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

///
//MARK:- ====== String
///
///
public extension String {
    //MARK:- Find First index of symbol in string
    func firstIndexOf(char: Character) -> Int? {
        for (i, t) in self.enumerated() {
            if t == char {
                return i
            }
        }
        return nil
    }
    
    //MARK:- Find Last index of symbol in string
    func lastIndexOf(char: Character) -> Int? {
        var res: Int? = nil
        for (i, t) in self.enumerated() {
            if t == char {
                res = i
            }
        }
        return res
    }
    
    //MARK:- Return Some Symbol N times
    ///Repeats string by given N times
    ///
    ///❗️prefer using `repeating(_ times: Int)` method instead
    ///```
    ///print("a".times(5))
    /////"aaaaa"
    ///```
    func times(_ N: Int) -> String {
        var s = ""
        for _ in 0..<N {
            s += self
        }
        return s
    }
    
    //MARK:- Repeating wrapper over standard method
    ///This method wraps the standard String init method "`String(repeating: String, count: Int)`" in more convenient way to use
    ///
    ///If "`times`" is less than or equal 0, returns empty string
    ///```
    ///print("a".repeating(5))
    /////"aaaaa"
    ///```
    func repeating(_ times: Int) -> String {
        return times > 0 ? String(repeating: self, count: times) : ""
    }
    
    //MARK:- Validate String as Email
    var isValidEmail: Bool {
        if !(self.contains("@") && self.contains(".")) {
            return false
        }
        let a = self.firstIndexOf(char: "@")!
        let b = self.lastIndexOf(char: ".")!
        if !(a > 0 && a + 1 < b) {
            return false
        }
        return true
    }
    
    
    //MARK:- Formatted Time Interval
    ///Formats time interval from given date (ISO 8601) to now in convenient way of mins, hours, etc.
    ///
    ///1. Date must be in UTC+03:00 (Moscow) w/o specified timezone, e.g. "2020-04-18T18:06:52.711Z"
    ///(18 Apr 2020, 18:06 in Moscow)
    ///Otherwise, will return incorrect interval.
    ///2. Returns "-/-" if date is not in ISO 8601, or if formatting failed.
    func formattedTimeIntervalToNow() -> String {
        ///values in seconds:
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        //let year = 365 * day
        
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: +3 * hour)
        formatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withFractionalSeconds
        ]
        let strDate = self.last == "Z" ? self : self+"Z"
        guard let date = formatter.date(from: strDate) else {
            return "-/-"
        }
        //print("Input:", date)
        
        ///current time w/ correction to UTC+03:00
        //print("Now:", Date(timeInterval: Double(3*hour), since: Date()))
        let seconds = Int(Date().timeIntervalSince(date)) + 3 * hour
        
        switch seconds {
        case month...:
            return "\(seconds / month)мес."
        case week...:
            return "\(seconds / week)нед."
        case day...:
            return "\(seconds / day)дн."
        case hour...:
            return "\(seconds / hour)ч."
        case minute...:
            return "\(seconds / minute)м."
        default:
            return "Только что"
        }
    }
 }


///
//MARK:- ====== Double
///
///
public extension Double {
    //MARK:- Round number to specified decimal places
    func rounded(places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        return (self * multiplier).rounded(.toNearestOrEven) / multiplier
    }
}


///
//MARK:- ====== Int
///
///
public extension Int {
    enum LikeType {
        case shortForm, fullForm
    }
    
    //MARK:- Format Likes
    func formattedToLikes(_ form : LikeType) -> String {
        guard form != .fullForm else {
            return "\(self)"
        }
        //let likeSymbol: String = "♡"
        let number = Double(self)
        let Billion = 1e9
        let Million = 1e6
        let Thousand = 1e3
        
        //var formattedLikes = ""
        switch number {
        //greater than:
        case Billion...:
            let res = Double(number) / Billion
            //formattedLikes = " \(res.rounded(places: 1))B"
            return "\(res.rounded(places: 1))B"
        case Million...:
            let res = Double(number) / Million
            //formattedLikes = " \(res.rounded(places: 1))M"
            return "\(res.rounded(places: 1))M"
        case Thousand...:
            let res = Double(number) / Thousand
            //formattedLikes = " \(res.rounded(places: 1))K"
            return "\(res.rounded(places: 1))K"
        default:
            //formattedLikes = " \(self)"
            return "\(self)"
        }
    }
    
    //MARK:- Count Deadline
    ///useful for adding to a periodic time observer
    func countDeadline(deadline: Int, deadline2: Int? = nil, condition: Bool = false, handler: (() -> Void)?, handler2: (() -> Void)? = nil) -> Int {
        if condition {
            return 0
        }

        if self == deadline {
            handler?()
            return self + 1
        }
        if self > deadline2 ?? deadline {
            handler2?()
            return 0
        }
        
        return self + 1
    }
}

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
    
    //MARK:- Seconds In
    ///Returns time interval in seconds for widely-used types of time
    static func secondsIn(_ time: TimeIntervalNames) -> Double {
        return time.seconds
    }
}
