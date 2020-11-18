//
//  UIActivityIndicatorView+Extensions.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {
    //MARK:- UI Bar Button Loading Indicator
    func enableInNavBar(of navigationItem: UINavigationItem){
        self.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
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
}
