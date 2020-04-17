//
//  IntroViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
