//
//  Extensions.swift
//  AvatarAppIos
//
//  Created by Владислав on 19.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import UIKit

public extension UIButton {
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

public extension String {
    func firstIndexOf(char: Character) -> Int? {
        for (i, t) in self.enumerated() {
            if t == char {
                return i
            }
        }
        return nil
    }
    
    func lastIndexOf(char: Character) -> Int? {
        var res: Int? = nil
        for (i, t) in self.enumerated() {
            if t == char {
                res = i
            }
        }
        return res
    }
 }

//MARK:- Show warning alert about incorrect e-mail
public extension UIViewController {
    func showEmailWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, введите почту заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
}

//MARK:- Show warning alert about incorrect Name input
public extension UIViewController {
    func showNameWarningAlert(with title: String){
        let alert = UIAlertController(title: title, message: "Пожалуйста, введите имя заново", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okBtn)
        present(alert, animated: true, completion: nil)
    }
}
