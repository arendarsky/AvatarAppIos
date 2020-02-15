//
//  PickingRoleViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class PickingRoleViewController: UIViewController {
    @IBOutlet weak var producerButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBAction func starButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showEmailVC", sender: sender)
        user.userType = "Star"
    }
    @IBAction func producerButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showEmailVC", sender: sender)
        user.userType = "Producer"
    }

    
    let spacingConstant: CGFloat = 30.0
    override func viewDidLoad() {
        super.viewDidLoad()
        starButton.centerTextAndImage(spacing: spacingConstant)
        starButton.setBackgroundColor(.lightGray, forState: .highlighted)
        producerButton.centerTextAndImage(spacing: spacingConstant)
        producerButton.setBackgroundColor(.lightGray, forState: .highlighted)
        if self.traitCollection.userInterfaceStyle == .dark {
            starButton.tintColor = .lightGray
            producerButton.tintColor = .lightGray
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.starButton.tintColor == UIColor.lightGray {
            starButton.tintColor = .darkGray
            producerButton.tintColor = .darkGray
        } else {
            starButton.tintColor = .lightGray
            producerButton.tintColor = .lightGray
        }
    }
}
