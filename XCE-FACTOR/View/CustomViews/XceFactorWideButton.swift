//
//  XceFactorWideButton.swift
//  AvatarAppIos
//
//  Created by Владислав on 25.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class XceFactorWideButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        //
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureButton()
    }
    
    func configureButton() {
        layer.cornerRadius = 12
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
            borderColorV = .systemPurple
        } else {
            backgroundColor = .black
            borderColorV = .purple
        }
        addBorderGradient(borderWidth: 5)
    }

}
