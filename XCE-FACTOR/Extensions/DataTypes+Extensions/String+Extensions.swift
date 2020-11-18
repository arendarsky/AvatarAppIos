//
//  String+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

extension String {
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