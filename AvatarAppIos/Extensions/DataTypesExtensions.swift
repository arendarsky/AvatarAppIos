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
    func times(_ N: Int) -> String {
        var s = ""
        for _ in 0..<N {
            s += self
        }
        return s
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
    //MARK:- Format Likes
    func formattedToLikes() -> String {
        let number = Double(self)
        let Billion = 1e9
        let Million = 1e6
        let Thousand = 1e3
        switch number {
        //greater than:
        case Billion...:
            let res = Double(number) / Billion
            return "♥ \(res.rounded(places: 1))B"
        case Million...:
            let res = Double(number) / Million
            return "♥ \(res.rounded(places: 1))M"
        case Thousand...:
            let res = Double(number) / Thousand
            return "♥ \(res.rounded(places: 1))K"
        default:
            return "♥ \(self)"
        }
    }
}
