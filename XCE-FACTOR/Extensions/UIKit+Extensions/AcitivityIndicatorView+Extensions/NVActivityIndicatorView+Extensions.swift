//
//  UIActivityIndicatorView+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension NVActivityIndicatorView {

    /// Set in NavBar
    func enableInNavBar(of navigationItem: UINavigationItem){
        //self.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        //self.type = .ballScale
        let barButton = UIBarButtonItem(customView: self)
        navigationItem.setRightBarButton(barButton, animated: true)
        isHidden = false
        startAnimating()
    }
    
    func disableInNavBar(of navigationItem: UINavigationItem, replaceWithButton: UIBarButtonItem?){
        stopAnimating()
        isHidden = true
        navigationItem.setRightBarButton(replaceWithButton, animated: true)
    }
    
    /// Set in the center of screen
    func enableCentered(in view: UIView, isCircle: Bool = false, width: CGFloat = 40.0) {
        frame = CGRect(x: (view.bounds.midX - width/2), y: (view.bounds.midY - width/2), width: width, height: width)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        layer.cornerRadius = isCircle ? (width / 2) : 4
        view.addSubview(self)
        /// constraints: center spinner vertically and horizontally in video view
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height),
            widthAnchor.constraint(equalToConstant: frame.width),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        startAnimating()
    }
    
}
