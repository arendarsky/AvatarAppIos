//
//MARK:  FirstUploadVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class FirstUploadVC: XceFactorViewController {

    @IBOutlet weak var addVideoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVideoButton.alignImageAndTitleVertically()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.performSegue(withIdentifier: "Show Intro at FirstUpload", sender: nil)
    }
    
    //MARK:- UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    //MARK:- UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }

    @IBAction func addVideoButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        performSegue(withIdentifier: "Show First Video Pick VC", sender: sender)
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        setApplicationRootVC(storyboardID: "MainTabBarController")
        
    }
    
}
