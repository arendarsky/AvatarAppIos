//
//  UIButton+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension UIButton {
    //MARK:- Make Spacing Between button text and image and center them in button
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
    
    //MARK:- Set Background Color for different states
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: forState)
        }
    }
    
    //MARK:- Add Blur to Button Background
    //!! was not tested for buttons with text
    func addBackgroundBlur(alpha: CGFloat = 0.9) {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

        //for cirle buttons ⬇️
        //blur.layer.cornerRadius = 0.5 * self.bounds.size.width
        blur.frame = self.bounds
        blur.alpha = alpha
        blur.isUserInteractionEnabled = false
        blur.clipsToBounds = true
        
        addSubview(blur)
        bringSubviewToFront(imageView!)
    }
    
    //MARK:- Align Button Image And Title Vertically
    func alignImageAndTitleVertically(padding: CGFloat = 10.0) {
        let imageSize = imageView?.frame.size ?? CGSize(width: 0, height: 0)
        let titleSize = titleLabel?.frame.size ?? CGSize(width: 0, height: 0)
        let totalHeight = imageSize.height + titleSize.height + padding

        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )

        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
}
