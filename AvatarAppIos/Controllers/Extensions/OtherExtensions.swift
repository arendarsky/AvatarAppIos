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
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
    
    //MARK:- Configure Backgrounds for NextStepButtons
    func configureBackgroundColors(){
        self.setBackgroundColor(.purple, forState: .highlighted)
        let normalColor = self.backgroundColor!
        self.backgroundColor = .systemTeal
        self.setBackgroundColor(normalColor, forState: .normal)
    }
}

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
    func times(_ n: Int) -> String {
        var s = ""
        for _ in 0..<n {
            s += self
        }
        return s
    }
 }

//MARK:- Show or hide labels with animation
public extension UILabel {
    //delay in seconds
    func setLabelWithAnimation(in view: UIView, hidden: Bool, delay: CGFloat){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) {
            UILabel.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.isHidden = hidden
            })
        }
    }
}

//MARK:- Set Cursor to Special Position in textfield
public extension UITextField {
    func setCursorPosition(to position: Int){
        if let cursorPosition = self.position(from: self.beginningOfDocument, offset: position) {
            self.selectedTextRange = self.textRange(from: cursorPosition, to: cursorPosition)
        }
    }
}
