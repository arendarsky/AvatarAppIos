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
        configureButtons()
        configureWebViev()
       // videoWebView.load(request)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    //server video request
    //let request = URLRequest(url: <#T##URL#>)
    
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
        if likeButton.tintColor == .systemRed {
            likeButton.tintColor = .darkGray
        } else {
            likeButton.tintColor = .systemRed
        }
        
        
    }

}

extension CastingViewController {
    func configureButtons() {
        likeButton.dropButtonShadow()
        dislikeButton.dropButtonShadow()
    }
    
    func configureWebViev() {
        videoWebView.backgroundColor = .clear
        videoWebView.clipsToBounds = true
        //videoWebView.layer.masksToBounds = true
        videoWebView.layer.cornerRadius = 16
        videoWebView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}
