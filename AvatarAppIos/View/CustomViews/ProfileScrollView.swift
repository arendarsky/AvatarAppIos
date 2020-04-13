//
//  ProfileScrollView.swift
//  AvatarAppIos
//
//  Created by Владислав on 13.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ProfileScrollView: UIScrollView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
