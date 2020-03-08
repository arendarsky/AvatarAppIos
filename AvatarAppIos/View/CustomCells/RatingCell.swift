//
//  RatingCell.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class RatingCell: UICollectionViewCell {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        // Initialization code
    }
    
}

extension RatingCell {
    func configureCell() {
        profileImageView.layer.cornerRadius = 15

        videoView.layer.cornerRadius = 25
        videoView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        descriptionView.layer.cornerRadius = 25
        descriptionView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
}
