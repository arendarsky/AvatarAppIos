//
//  CustomShareActivity.swift
//  XCE-FACTOR
//
//  Created by Владислав on 11.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class CustomShareActivity: UIActivity {
    
    var _activityTitle: String
    var _activityImage: UIImage?
    var activityItems = [Any]()
    var action: ([Any]) -> Void
    
    init(title: String, image: UIImage?, items: [Any], action: @escaping (([Any]) -> Void)) {
        _activityTitle = title
        _activityImage = image
        activityItems = items
        self.action = action
        super.init()
    }

    override var activityTitle: String? {
        return _activityTitle
    }

    override var activityImage: UIImage? {
        return _activityImage
    }
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType("shpmm.XCE-FACTOR.shareActivity")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
//    override func prepare(withActivityItems activityItems: [Any]) {
//        self.activityItems = activityItems
//    }
    
    override func perform() {
        action(activityItems)
        activityDidFinish(true)
    }
}
