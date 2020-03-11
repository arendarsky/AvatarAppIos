//
//  NotificationCell.swift
//  AvatarAppIos
//
//  Created by Владислав on 12.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureCell() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        badgeImageView.layer.cornerRadius = badgeImageView.frame.width / 2
        //badgeImageView.backgroundColor = .red
    }

}
