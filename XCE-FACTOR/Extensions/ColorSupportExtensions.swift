//
//MARK:  ColorSupportExtensions.swift
//  AvatarAppIos
//
//  Created by Владислав on 22.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

// Here are collected general extensions to change system (light) colors to dark ones in iOS 12
// ❗️Background color for UIViewController's view is set in its base subclass 'XceFactorViewController'
//TODO: Create ColorManager

import UIKit

//MARK:- UIView
public extension UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {} else {
            switch self.backgroundColor {
            case UIColor.white:
                self.backgroundColor = .black
            default:
                break
            }
            
            //MARK:- In case of self is UILabel
            if let label = self as? UILabel {
                switch label.textColor {
                case UIColor.black, UIColor.darkText:
                    label.textColor = .white
                case UIColor.darkGray:
                    label.textColor = .lightGray
                case UIColor.lightGray:
                    label.textColor = .darkGray
                default:
                    break
                }
            }
        }
    }
    
    var recursiveSubviews: [UIView] {
        var subviews = self.subviews.compactMap({$0})
        subviews.forEach { subviews.append(contentsOf: $0.recursiveSubviews) }
        return subviews
    }
}

//MARK:- UIScrollView
public extension UIScrollView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {} else {
            self.backgroundColor = .black
            
            //MARK:- In case of self is UITextView
            if let textView = self as? UITextView {
                switch textView.textColor {
                case UIColor.black, UIColor.darkText:
                    textView.textColor = .white
                case UIColor.darkGray:
                    textView.textColor = .lightGray
                default:
                    break
                }
            }
        }
    }
}

//MARK:- UIControl
public extension UIControl {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {} else {
            switch self.tintColor {
            case UIColor.black, UIColor.darkText:
                self.tintColor = .white
            case UIColor.darkGray:
                self.tintColor = .lightGray
            default:
                break
            }
        }
    }
}

//MARK:- UITextField
public extension UITextField {
    func setPlaceholderTextColor(_ color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(
            string: self.placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {} else {
            self.setPlaceholderTextColor(UIColor.white.withAlphaComponent(0.4))
            self.textColor = .white
            self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        }
    }
}


 //MARK:- UITabBarController
public extension UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {} else {
            self.tabBar.barStyle = .black
            self.tabBar.tintColor = .white
            let barItems = self.tabBar.items!
            barItems.first?.image = IconsManager.getIcon(.barBell)
            barItems[1].image =     IconsManager.getIcon(.barHeart)
            barItems[2].image =     IconsManager.getIcon(.barStar)
            barItems.last?.image =  IconsManager.getIcon(.barProfile)
        }
    }
}


//MARK:- UIAlertController

public extension UIAlertController {
    
    //MARK:- Set Title Color
    func setTitleColor(_ color: UIColor) {
        let attributedString = NSAttributedString(
            string: self.title ?? "",
            attributes: [NSAttributedString.Key.foregroundColor : color]
        )
        self.setValue(attributedString, forKey: "attributedTitle")
    }
    
    //MARK:- Set Message Color
    func setMessageColor(_ color: UIColor) {
        let attributedString = NSAttributedString(
            string: self.message ?? "",
            attributes: [NSAttributedString.Key.foregroundColor : color]
        )
        self.setValue(attributedString, forKey: "attributedMessage")
    }
    
    //MARK:- Cancel Action View
    var cancelActionView: UIView? {
        return view.recursiveSubviews.compactMap({
            $0 as? UILabel}
        ).first(where: {
            $0.text == actions.first(where: { $0.style == .cancel })?.title
        })?.superview?.superview
    }
    
    //MARK:- View Will Layout Subviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 13, *) {} else {
            let alertColor = UIColor.darkGray
            
            let contentView = self.view.subviews.first?.subviews.first
            contentView?.subviews.first?.backgroundColor = alertColor
            cancelActionView?.backgroundColor = alertColor
            
            self.setTitleColor(UIColor.white)
            self.setMessageColor(UIColor.white)
            self.view.tintColor = .white
        }
    }
}
