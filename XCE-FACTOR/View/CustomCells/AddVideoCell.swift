//
//  AddVideoCell.swift
//  XCE-FACTOR
//
//  Created by Владислав on 05.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

protocol AddVideoCellDelegate: class {
    func addNewVideoButtonPressed(_ sender: UIButton)
}

class AddVideoCell: UICollectionViewCell {
    
    weak var delegate: AddVideoCellDelegate?
    
    @IBOutlet weak var addNewVideoButton: UIButton!
    @IBOutlet weak var zeroVideosLabel: UILabel!
    
    override func awakeFromNib() {
        configureCell()
    }
    
    @IBAction func addNewVideoButtonPressed(_ sender: UIButton) {
        contentView.scaleOut()
        delegate?.addNewVideoButtonPressed(sender)
        print("pressed")
    }
    
    func configureCell() {
        addNewVideoButton.isEnabled = (Globals.user.videosCount ?? Int.max) < Globals.maxVideosAllowed
        self.contentView.layer.cornerRadius = 10
        
        addNewVideoButton.addGradient(
            firstColor: UIColor(red: 0.879, green: 0.048, blue: 0.864, alpha: 0.3),
            secondColor: UIColor(red: 0.667, green: 0.239, blue: 0.984, alpha: 0.3),
            transform: CGAffineTransform(a: 1, b: 0, c: 0, d: 38.94, tx: 0, ty: -18.97)
        )
        addNewVideoButton.backgroundColor = .black
        
        if #available(iOS 13.0, *) {} else {
            addNewVideoButton.setImage(IconsManager.getIcon(.plusSmall), for: .normal)
        }
        contentView.isUserInteractionEnabled = true
        
        addNewVideoButton.addTarget(self, action: #selector(buttonHighlighted), for: [.touchDown, .touchDragInside])
        addNewVideoButton.addTarget(self, action: #selector(buttonReleased), for: [.touchCancel, .touchDragOutside, .touchUpOutside])
    }
    
    func setViews(accordingTo isPublicProfile: Bool) {
        addNewVideoButton.isHidden = isPublicProfile
        zeroVideosLabel.isHidden = !isPublicProfile
    }
    
}

extension AddVideoCell {
    
    @objc func buttonHighlighted() {
        contentView.scaleIn()
        //addNewVideoButton.scaleIn()
    }
    
    @objc func buttonReleased() {
        contentView.scaleOut()
        //addNewVideoButton.scaleOut()
    }
}
