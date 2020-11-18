//
//  Int+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation

extension Int {

    enum LikeType {
        case shortForm, fullForm
    }
    
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

    /// Useful for adding to a periodic time observer
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

