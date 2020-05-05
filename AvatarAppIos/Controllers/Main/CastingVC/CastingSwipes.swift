//
//MARK:  CastingSwipes.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension CastingViewController {
    enum SwipeDirection {
        case left
        case right
    }
    
    //MARK:- Simulate Swipe
    func simulateSwipe(_ direction: SwipeDirection, handler: (() -> Void)?) {
        let yShift: CGFloat = 100
        var xShift: CGFloat = 700
        var fullRotationAngle = CGFloat.pi * 35 / 360

        if direction == .left {
            fullRotationAngle *= -1
            xShift *= -1
        }
        hapticsGenerator.impactOccurred()
        indicatorImageView.image = direction == .right ? UIImage(systemName: "heart.fill") : UIImage(systemName: "xmark")
        indicatorImageView.alpha = 1
        indicatorImageView.bouncingAnimation()
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.layoutSubviews],
        animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.01) {
                self.castingView.transform = .identity
            }
            UIView.addKeyframe(withRelativeStartTime: 0.01, relativeDuration: 0.99) {
                let point = CGPoint(x: self.view.center.x + xShift, y: self.view.center.y + yShift)
                self.castingView.center = point
                self.castingView.transform = CGAffineTransform(rotationAngle: fullRotationAngle)
                self.castingView.alpha = 0
                self.nextCastingView.transform = .identity
            }
        },
        completion: { (ended) in
            //MARK:- Animation Ended
            self.resetCard(animated: false)
            handler?()
        })
    }
    
    //MARK:- Show Image on Highlight
    @objc func likeButtonsHighlighted(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.indicatorImageView.alpha = 0.5
            self.indicatorImageView.image = sender == self.dislikeButton ? sender.currentImage : UIImage(systemName: "heart.fill")
        }
    }
    
    //MARK:- Hide Image on Release
    @objc func likeButtonsReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.indicatorImageView.alpha = 0.0
        }
    }
    
    //MARK:- Swipe Actions
    @IBAction func viewPanned(_ sender: UIPanGestureRecognizer) {
        //preparing the stuff
        (likeButton.isEnabled, dislikeButton.isEnabled) = (false, false)
        (updateButton.isHidden, notificationLabel.isHidden) = (true, true)
        setControls(enabled: false)

        let fullRotationAngle = CGFloat.pi * 35 / 360
        let screenWidthPart: CGFloat = 0.25
        let marginValue: CGFloat = view.center.x * screenWidthPart
        let card = sender.view!
        let point = sender.translation(in: view)
        
        ///delta of Card's X-coordinate from superview center
        let dx = card.center.x - view.center.x
        ///the same dx but in range of [0,1]
        let xShiftFraction = dx / view.center.x
        
        //MARK:- Direct Pan Actions
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        card.transform = CGAffineTransform(rotationAngle: xShiftFraction * fullRotationAngle)
        
        extraSwipeAnimations(card, backgrndCard: nextCastingView, xShiftFraction: xShiftFraction, marginValue: marginValue)

        //MARK:- Pan Ended
        ///~ when touches ended
        if sender.state == .ended {
            (likeButton.isEnabled, dislikeButton.isEnabled) = (true, true)
            setControls(enabled: true)
            
            if card.center.x < marginValue || card.center.x > view.frame.width - marginValue {
                let isLike = card.center.x - marginValue > 0
                finishSwipe(for: card, direction: isLike ? .right : .left, inheritedAngle: fullRotationAngle) {
                    //MARK:- Load Next Video
                    self.setLike(isLike: isLike, animated: false)
                }
                return
            }
            resetCard()
        }
    }
    
    //MARK:- Extra Swipe Animations
    ///Additional Swipe animations for better User Experience.
    ///
    ///Includes background view and buttons scaling and displaying like/dislike image indicators
    func extraSwipeAnimations(_ mainCard: UIView, backgrndCard: UIView, xShiftFraction: CGFloat, marginValue: CGFloat) {
        
        let buttonsScaleRate: CGFloat = 0.2
        let buttonsScaleTransform = CGAffineTransform(scaleX: 1 + buttonsScaleRate * abs(xShiftFraction), y: 1 + buttonsScaleRate * abs(xShiftFraction))
        
        // • Scaling background card
        let scale = backViewScale + (1 - backViewScale) * abs(xShiftFraction)
        backgrndCard.transform = CGAffineTransform(scaleX: scale, y: scale)
        backgrndCard.alpha = 0.5 * (1 + abs(xShiftFraction))

        // • Setting Indicator Image
        if xShiftFraction > 0 {
            indicatorImageView.image = UIImage(systemName: "heart.fill")
            likeButton.transform = buttonsScaleTransform
        // and scaling like/dislike buttons
        } else {
            indicatorImageView.image = UIImage(systemName: "xmark")
            dislikeButton.transform = buttonsScaleTransform
        }
        
        if mainCard.center.x < marginValue || mainCard.center.x > view.frame.width - marginValue {
            //MARK:- • Image Bounce
            indicatorImageView.alpha = 1
            if !imageBounced {
                indicatorImageView.bouncingAnimation()
                imageBounced = true
            }
            //MARK:- • Perform haptics
            if !hapticsPerformed {
                hapticsGenerator.impactOccurred()
                hapticsPerformed = true
            }
        } else {
            indicatorImageView.alpha = abs(xShiftFraction)
            imageBounced = false
            hapticsPerformed = false
        }
    }

    //MARK:- Finish Swipe
    ///Finish swipe animation, prepare views for reuse and perform further actions if needed
    ///
    ///Throws card out of screen and then silently resets all transformations
    private func finishSwipe(for card: UIView, direction: SwipeDirection, inheritedAngle: CGFloat, handler: (() -> Void)?) {
        let startTransform = card.transform
        let yShift: CGFloat = 100
        var xShift: CGFloat = 200
        var fullRotationAngle = inheritedAngle
        if direction == .left {
            fullRotationAngle *= -1
            xShift *= -1
        }
        
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: [.layoutSubviews],
        animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.01) {
                card.transform = startTransform
            }
            UIView.addKeyframe(withRelativeStartTime: 0.01, relativeDuration: 0.99) {
                card.center = CGPoint(x: card.center.x + xShift, y: card.center.y + yShift)
                card.transform = CGAffineTransform(rotationAngle: fullRotationAngle)
                card.alpha = 0
                self.nextCastingView.transform = .identity
            }
        },
        completion: { (ended) in
            self.resetCard(animated: false)
            handler?()
        })
    }
    
    //MARK:- Reset Card
    ///- parameter animated: Enable/disable animation. Does not affect 'like' and 'dislike' buttons' animation
    ///- parameter duration: Animation duration, works for swiped views only if 'animated' param is set to 'true'
    func resetCard(animated: Bool = true, duration: Double = 0.2) {
        UIView.animate(withDuration: animated ? duration : 0.0) {
            self.castingView.center = self.view.center
            self.castingView.alpha = 1
            self.castingView.transform = .identity
            self.indicatorImageView.alpha = 0
            self.indicatorImageView.transform = .identity
            self.nextCastingView.transform = CGAffineTransform(scaleX: self.backViewScale, y: self.backViewScale)
            self.nextCastingView.center = self.view.center
            self.nextCastingView.alpha = 1
        }
        UIView.animate(withDuration: duration) {
            self.likeButton.transform = .identity
            self.dislikeButton.transform = .identity
        }
    }
    
    //MARK:- Prepare Buttons for Swipes
    func prepareForSwipes() {
        
        nextCastingView.transform = CGAffineTransform(scaleX: backViewScale, y: backViewScale)
        nextCastingView.dropShadow()
        nextNameLabel.dropShadow(color: .black, opacity: 0.8)
        
        likeButton.addTarget(self, action: #selector(likeButtonsHighlighted(_:)), for: [.touchDown, .touchDragEnter, .touchDragInside])
        likeButton.addTarget(self, action: #selector(likeButtonsReleased(_:)), for: [.touchCancel, .touchDragExit, .touchDragOutside, .touchUpOutside])
        dislikeButton.addTarget(self, action: #selector(likeButtonsReleased(_:)), for: [.touchCancel, .touchDragExit, .touchDragOutside, .touchUpOutside])
        dislikeButton.addTarget(self, action: #selector(likeButtonsHighlighted(_:)), for: [.touchDown, .touchDragEnter, .touchDragInside])
    }
}
