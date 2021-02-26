//
//  ResizableButton.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 12.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

final class ResizableButton: UIButton {

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
        layer.cornerRadius = bounds.height / 2

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

