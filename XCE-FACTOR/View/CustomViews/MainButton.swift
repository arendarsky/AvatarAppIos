//
//  MainButton.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 18.11.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class MainButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self,
                  action: #selector(buttonHighlighted),
                  for: [.touchDown, .touchDragEnter])
        addTarget(self,
                  action: #selector(buttonReleased),
                  for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
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

    // MARK: - Button Animations

    @objc private func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }

    @objc private func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
}
