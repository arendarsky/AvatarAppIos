//
//MARK:  SemifinalistCell.swift
//  XCE-FACTOR
//
//  Created by Владислав on 30.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

//MARK:- Delegate Methods
protocol SemifinalistCellDelegate: class {
    func semifinalistCell(_ sender: SemifinalistCell, didTapOnImageView imageView: UIImageView)
}

class SemifinalistCell: UICollectionViewCell {
    
    weak var delegate: SemifinalistCellDelegate?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    //MARK:- Awake From Nib
    override func awakeFromNib() {
        configureCell()
    }
   
    //MARK:- Configure Cell
    func configureCell() {
        //profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.tintColor = .systemPurple
        profileImageView.layer.borderColor = UIColor.systemPurple.cgColor
        profileImageView.layer.borderWidth = 2.5
        profileImageView.isUserInteractionEnabled = true
//        profileImageView.addTapGestureRecognizer {
//            self.delegate?.semifinalistCell(self, didTapOnImageView: self.profileImageView)
//        }
    }
}
