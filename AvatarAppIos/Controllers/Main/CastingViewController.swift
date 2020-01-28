//
//  CastingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 28.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import WebKit

class CastingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        castingView.dropShadow()
        likeButton.dropButtonShadow()
        dislikeButton.dropButtonShadow()
        videoWebView.backgroundColor = .clear
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var castingView: UIView!
    @IBOutlet weak var videoWebView: WKWebView!
    @IBOutlet weak var starName: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func showFullVideoButtonPressed(_ sender: Any) {
    }
    @IBAction func dislikeButtonPressed(_ sender: Any) {
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
    }
    
    
}
