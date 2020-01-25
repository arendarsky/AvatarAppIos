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
        starButton.backgroundColor = .lightGray
        performSegue(withIdentifier: "showEmailVC", sender: sender)
    }
    @IBAction func producerButtonPressed(_ sender: Any) {
        producerButton.backgroundColor = .lightGray
        performSegue(withIdentifier: "Show ProducerStartScreen", sender: sender)
    }
    
    
    let spacingConstant: CGFloat = 30.0
    override func viewDidLoad() {
        super.viewDidLoad()
        producerButton.centerTextAndImage(spacing: spacingConstant)
        //the corner radius is set in storyboard -> identity inspector
        
        starButton.centerTextAndImage(spacing: spacingConstant)
    }
    
}
