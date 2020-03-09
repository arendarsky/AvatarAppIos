//
//  StarStatsViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class StarStatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    @IBOutlet weak var generalView: UIView!
    @IBOutlet weak var viewsView: UIView!
    @IBOutlet weak var likesView: UIView!
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
}

extension StarStatsViewController {
    func configureViews(){
        generalView.layer.cornerRadius = 12
        viewsView.layer.cornerRadius = 12
        likesView.layer.cornerRadius = 12
        ratingView.layer.cornerRadius = 12
    }
}
