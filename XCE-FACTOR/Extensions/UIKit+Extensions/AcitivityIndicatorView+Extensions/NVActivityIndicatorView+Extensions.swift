//
//  UIActivityIndicatorView+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

public extension NVActivityIndicatorView {

    //MARK:- Set in NavBar
    func enableInNavBar(of navigationItem: UINavigationItem){
        //self.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        //self.type = .ballScale
        let barButton = UIBarButtonItem(customView: self)
        navigationItem.setRightBarButton(barButton, animated: true)
        self.isHidden = false
        self.startAnimating()
    }
    
    func disableInNavBar(of navigationItem: UINavigationItem, replaceWithButton: UIBarButtonItem?){
        self.stopAnimating()
        self.isHidden = true
        navigationItem.setRightBarButton(replaceWithButton, animated: true)
    }
    
    //MARK:- Set in the center of screen
    func enableCentered(in view: UIView, isCircle: Bool = false, width: CGFloat = 40.0) {
        self.frame = CGRect(x: (view.bounds.midX - width/2), y: (view.bounds.midY - width/2), width: width, height: width)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.cornerRadius = isCircle ? (width / 2) : 4
        view.addSubview(self)
        //MARK:- constraints: center spinner vertically and horizontally in video view
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: self.frame.height),
            self.widthAnchor.constraint(equalToConstant: self.frame.width),
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        self.startAnimating()
    }
    
}
