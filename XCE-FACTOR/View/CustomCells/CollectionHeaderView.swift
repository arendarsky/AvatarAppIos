//
//  CollectionHeaderView.swift
//  AvatarAppIos
//
//  Created by Владислав on 06.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class CollectionHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var sectionHeader: UILabel!
    
    override func awakeFromNib() {
        backgroundColor = .systemBackground
    }
    
}
