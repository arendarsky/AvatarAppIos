//
//MARK:  Extensions.swift
//  AvatarAppIos
//
//  Created by Владислав on 19.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import NVActivityIndicatorView
import SafariServices

//MARK:- ====== UIButton
///
///

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
    func configureHighlightedColors(color: UIColor = .white, alpha: CGFloat = 0.8) {
        self.setBackgroundColor(color.withAlphaComponent(alpha), forState: .highlighted)
        let normalColor = self.backgroundColor!
        self.backgroundColor = .systemTeal
        self.setBackgroundColor(normalColor, forState: .normal)
    }
    
    //MARK:- Drop Button Shadow
    func dropButtonShadow(scale: Bool = true) {
        //let shadowLayer = CAShapeLayer()
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 20

        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: 10).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        //layer.insertSublayer(shadowLayer, at: 0)
    }
    
    //MARK:- Add Blur to Button Background
    //!! was not tested for buttons with text
    func addBlur(alpha: CGFloat = 0.9){
        let blur = UIVisualEffectView(effect: UIBlurEffect(style:
            .regular))
        blur.frame = self.bounds
        blur.alpha = alpha
        blur.isUserInteractionEnabled = false
        //for cirle buttons ⬇️
        //blur.layer.cornerRadius = 0.5 * self.bounds.size.width
        blur.clipsToBounds = true
        self.addSubview(blur)
        self.bringSubviewToFront(self.imageView!)
    }
    
    //MARK:- Set Button With Animation
    func setButtonWithAnimation(in view: UIView, hidden: Bool, startDelay: CGFloat = 0.0, duration: TimeInterval = 0.5){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(startDelay * 1000))) {
            UIButton.transition(with: view, duration: duration, options: .transitionCrossDissolve, animations: {
                self.isHidden = hidden
            })
        }
    }
    
    //MARK:- Align Button Image And Title Vertically
    func alignImageAndTitleVertically(padding: CGFloat = 10.0) {
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
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


///
///
//MARK:- ====== UILabel
///
///

//MARK:- Show or hide labels with animation
public extension UILabel {
    //delay in seconds
    func setLabelWithAnimation(in view: UIView, hidden: Bool, startDelay: CGFloat = 0.0, duration: TimeInterval = 0.5){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(startDelay * 1000))) {
            UILabel.transition(with: view, duration: duration, options: .transitionCrossDissolve, animations: {
                self.isHidden = hidden
            })
        }
    }
}


///
///
//MARK:- ====== UITextField
///
///

public extension UITextField {
    //MARK:- Set Cursor to Special Position in textfield
    func setCursorPosition(to position: Int){
        if let cursorPosition = self.position(from: self.beginningOfDocument, offset: position) {
            self.selectedTextRange = self.textRange(from: cursorPosition, to: cursorPosition)
        }
    }
    
    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }

    //MARK:- Add Padding to the TextField
    func addPadding(_ padding: PaddingSide) {

        self.leftViewMode = .always
        self.layer.masksToBounds = true

        switch padding {

        case .left(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = paddingView
            self.rightViewMode = .always

        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = paddingView
            self.rightViewMode = .always

        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = paddingView
            self.leftViewMode = .always
            // right
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
}

//MARK:- ====== UIView
///
///

public extension UIView {
    
    //MARK:- Adds some properties to the storyboard
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    
    //MARK:- Drop Shadow View
    func dropShadow(scale: Bool = true, color: UIColor = .white, shadowRadius: CGFloat = 5.0, opacity: Float = 0.5, isMaskedToBounds: Bool = false, path: Bool = false, shouldRasterize: Bool = true) {
        layer.masksToBounds = isMaskedToBounds
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = shadowRadius

        if path {
            layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        }
        layer.shouldRasterize = shouldRasterize
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    //MARK:- Add Gradient to any UIView
    ///deletes existing view background color and makes a gradient one
    func addGradient(firstColor: UIColor = UIColor(red: 0.879, green: 0.048, blue: 0.864, alpha: 1),
                     secondColor: UIColor = UIColor(red: 0.667, green: 0.239, blue: 0.984, alpha: 1),
                     transform: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: 38.94, tx: 0, ty: -18.97)) {
        
        self.backgroundColor = .white

        let layer0 = CAGradientLayer()

        layer0.colors = [
          firstColor.cgColor,
          secondColor.cgColor
        ]

        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)

        layer0.transform = CATransform3DMakeAffineTransform(transform)

        layer0.bounds = self.bounds.insetBy(dx: -0.5 * self.bounds.size.width, dy: -0.5 * self.bounds.size.height)
        layer0.position = self.center

        self.layer.addSublayer(layer0)
    }
    
    //MARK:- Set View With Animation
    func setViewWithAnimation(in view: UIView, hidden: Bool, startDelay: CGFloat = 0.0, duration: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(startDelay * 1000))) {
            UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve, animations: {
                self.isHidden = hidden
            })
        }
    }
    
    //MARK:- View Scale Animation
    func scaleIn(scale: CGFloat = 0.96) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    func scaleOut() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    //MARK:- View Bounce Animation
    func bouncingAnimation() {
        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: CGFloat(0.20), initialSpringVelocity: CGFloat(6.0), options: UIView.AnimationOptions.allowUserInteraction, animations: { self.transform = CGAffineTransform.identity }, completion: { Void in()  }
        )
    }
        
    
    //MARK:- Add Tap Gesture Recognizer to a View
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }

    fileprivate typealias Action = (() -> Void)?
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }


    func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }


    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
    /* Not needed due to the exsisting system function (iOS 11+)
       //MARK:- Round Only Necessary Corners
       func roundCorners(corners: UIRectCorner, radius: CGFloat) {
           let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
           let mask = CAShapeLayer()
           mask.path = path.cgPath
           layer.mask = mask
       }
    */
    
}


//MARK:- ====== UIImageView
///
///

public extension UIImageView {
    //MARK:- Get Profile Image Request
    func setProfileImage(named: String, cache: ((UIImage?) -> Void)? = nil) {
        Profile.getProfileImage(name: named) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print(error)
                self.image = UIImage(systemName: "person.crop.circle.fill")
            case .results(let profileImage):
                self.image = profileImage
                cache?(profileImage)
            }
        }
    }
}


//MARK:- ====== UIImage
///
///

public extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}


//MARK:- ====== UITextView
///
///

public extension UITextView {
    enum BorderType {
        case top
        case bottom
        case both
    }
    
    //MARK:- Add Necessary Borders
    func addBorders(color: UIColor, border: BorderType) {
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = color.cgColor
        bottomBorder.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        bottomBorder.name = "BottomBorder"
        
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        topBorder.name = "TopBorder"
        
        switch border {
        case .both:
            layer.addSublayer(bottomBorder)
            layer.addSublayer(topBorder)
        case .top:
            layer.addSublayer(topBorder)
        case .bottom:
            layer.addSublayer(bottomBorder)
        }
    }
}


//MARK:- ====== Activity Indicators
///
///
public extension UIActivityIndicatorView {
    //MARK:- UI Bar Button Loading Indicator
    func enableInNavBar(of navigationItem: UINavigationItem){
        self.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let barButton = UIBarButtonItem(customView: self)
        navigationItem.setRightBarButton(barButton, animated: true)
        self.isHidden = false
        self.startAnimating()
    }
    
    func disableInNavBar(of navigationItem: UINavigationItem, replaceWithButton: UIBarButtonItem?){
        self.stopAnimating()
        self.isHidden = true
        navigationItem.setRightBarButton(replaceWithButton, animated: true)
    }
}

//MARK:- Custom Bar Button Loading Indicator

public extension NVActivityIndicatorView {

    //MARK:- Set in NavBar
    func enableInNavBar(of navigationItem: UINavigationItem){
        //self.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        //self.type = .ballScale
        let barButton = UIBarButtonItem(customView: self)
        navigationItem.setRightBarButton(barButton, animated: true)
        self.isHidden = false
        self.startAnimating()
    }
    
    func disableInNavBar(of navigationItem: UINavigationItem, replaceWithButton: UIBarButtonItem?){
        self.stopAnimating()
        self.isHidden = true
        navigationItem.setRightBarButton(replaceWithButton, animated: true)
    }
    
    //MARK:- Set in the center of screen
    func enableCentered(in view: UIView, isCircle: Bool = false, width: CGFloat = 40.0) {
        self.frame = CGRect(x: (view.bounds.midX - width/2), y: (view.bounds.midY - width/2), width: width, height: width)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.cornerRadius = isCircle ? (width / 2) : 4
        view.addSubview(self)
        //MARK:- constraints: center spinner vertically and horizontally in video view
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: self.frame.height),
            self.widthAnchor.constraint(equalToConstant: self.frame.width),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        self.startAnimating()
    }
    
}
