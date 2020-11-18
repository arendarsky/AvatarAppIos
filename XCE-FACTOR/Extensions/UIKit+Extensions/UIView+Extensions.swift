//
//  AvatarAppIos
//
//  Created by Владислав on 19.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import SafariServices

extension UIView {

    // MARK: - @IBInspectable
    // Adds some properties to the storyboard

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

    //MARK: - Enums

    enum NotificationType {
        case serverError
        case zeroNotifications
        case zeroPeopleInRating
        case other(String)
    }

    enum BorderType {
        case top
        case bottom
        case both
    }
    
    //MARK:- Drop View Shadow
    /// - parameter forceBackground: use it when View has very light or clear background but the shadow has to be dropped to the View's frame
    func dropShadow(scale: Bool = true, color: UIColor = .white, shadowRadius: CGFloat = 3.0, opacity: Float = 0.5, isMaskedToBounds: Bool = false, path: Bool = false, shouldRasterize: Bool = true, forceBackground: Bool = false) {
        
        if forceBackground {
            backgroundColor = color.withAlphaComponent(0.01)
        }
        layer.masksToBounds = isMaskedToBounds
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = shadowRadius

        if path {
            layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        }
        layer.shouldRasterize = shouldRasterize
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addBlur(alpha: CGFloat = 1, style: UIBlurEffect.Style = .regular) {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: style))
        blur.frame = bounds
        blur.alpha = alpha
        blur.isUserInteractionEnabled = false
        blur.clipsToBounds = true
        //addSubview(blur)
        insertSubview(blur, at: 0)
    }
    
    //MARK:- Add Gradient to any UIView
    ///deletes existing view background color and makes a gradient one
    func addGradient(firstColor: UIColor = UIColor(red: 0.879, green: 0.048, blue: 0.864, alpha: 1),
                     secondColor: UIColor = UIColor(red: 0.667, green: 0.239, blue: 0.984, alpha: 1),
                     transform: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: 38.94, tx: 0, ty: -18.97)) {
        backgroundColor = .white

        let layer0 = CAGradientLayer()

        layer0.colors = [
          firstColor.cgColor,
          secondColor.cgColor
        ]

        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)

        layer0.transform = CATransform3DMakeAffineTransform(transform)

        layer0.bounds = bounds.insetBy(dx: -0.5 * bounds.size.width, dy: -0.5 * bounds.size.height)
        layer0.position = center

        layer.addSublayer(layer0)
    }
    
    //MARK:- Add Border Gradient
    func addBorderGradient(borderWidth: CGFloat = 1.0,
                           firstColor: UIColor = UIColor(red: 0.879, green: 0.048, blue: 0.864, alpha: 1),
                           secondColor: UIColor = UIColor(red: 0.667, green: 0.239, blue: 0.984, alpha: 1)) {
        
        borderColorV = .clear
        clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: frame.size)
        gradient.colors = [firstColor.cgColor, secondColor.cgColor]

        let shape = CAShapeLayer()
        shape.lineWidth = borderWidth
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)

        layer.addSublayer(gradient)
        
    }
    
    //MARK:- Set View With Animation
    func setViewWithAnimation(in view: UIView, hidden: Bool, startDelay: CGFloat = 0.0, duration: TimeInterval = 0.5, handler: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(startDelay * 1000))) {
            UIView.transition(with: view,
                              duration: duration,
                              options: .transitionCrossDissolve,
                              animations: { self.isHidden = hidden},
                              completion: { completed in
                                handler?()
            })
        }
    }
    
    func showNotification(_ notification: NotificationType) {
        switch notification {
        case .serverError:
            (self as? UILabel)?.text = "Не удалось\nсвязаться с сервером"
        case .zeroNotifications:
            (self as? UILabel)?.text = "Здесь отображаются голоса тех, кто хочет видеть Вас в финале шоу XCE FACTOR 2020. Загрузите видео и отправьте его в Кастинг, чтобы получить первые лайки"
        case .zeroPeopleInRating:
            (self as? UILabel)?.text = "Рейтинг пока пуст"
        case .other(let text):
            (self as? UILabel)?.text = text
        }
        
        if #available(iOS 13.0, *) { } else {
            (self as? UILabel)?.textColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
        
        isHidden = false
    }
    
    //MARK:- View Scale Animation
    func scaleIn(scale: CGFloat = 0.96) {
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: [.allowUserInteraction, .curveEaseIn],
                       animations: { self.transform = CGAffineTransform(scaleX: scale, y: scale) },
                       completion: nil)
    }
    
    func scaleOut() {
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: [.allowUserInteraction, .curveEaseIn],
                       animations: { self.transform = CGAffineTransform.identity },
                       completion: nil)
    }
    
    //MARK:- Simple Bounce Animation
    func simpleBounce() {
        let startScale = transform
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = startScale.scaledBy(x: 1.1, y: 1.1)
        }, completion: { (ended) in
            UIView.animate(withDuration: 0.1) {
                self.transform = startScale
            }
        })
    }
    
    //MARK:- Advanced Bounce
    func bouncingAnimation() {
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: CGFloat(0.4), initialSpringVelocity: CGFloat(6.0), options: UIView.AnimationOptions.allowUserInteraction,
        animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func addBorders(_ border: BorderType, color: UIColor, borderWidth: CGFloat = 1) {
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = color.cgColor
        bottomBorder.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: borderWidth)
        bottomBorder.name = "BottomBorder"
        
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: borderWidth)
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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))

        isUserInteractionEnabled = true
        tapGestureRecognizerAction = action

        addGestureRecognizer(tapGestureRecognizer)
    }


    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
}
