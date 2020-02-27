//
//  PresenationControllers.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import UIKit

public class FifthSizePresentationController : UIPresentationController {
    override public var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let theView = containerView else {
                return CGRect.zero
            }

            return CGRect(x: 0, y: theView.bounds.height/(5/4), width: theView.bounds.width, height: theView.bounds.height/5)
        }
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            
        }
    }
}
