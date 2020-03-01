//
//  MessageFrameVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 01.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class MessageFrameVC: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var messageView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.setViewWithAnimation(in: view, hidden: false, startDelay: 0.25, duration: 0.35)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        backgroundView.isHidden = true
    }
        
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: view) {
            if !(messageView.frame.contains(location)) {
                //print("touch outside container")
                    
                self.dismiss(animated: true, completion: nil)
                    
            } else {
                //print("touch inside container")
            }
        }
    }
}
