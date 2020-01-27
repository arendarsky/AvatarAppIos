//
//  ProducerStartReadyVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 20.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ProducerStartReadyVC: UIViewController {
    @IBOutlet weak var someImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonPressed(_ sender: Any) {
        //nothing for now
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.configureBackgroundColors()
    }

}
