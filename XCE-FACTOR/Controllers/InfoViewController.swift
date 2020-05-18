//
//  InfoViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 18.04.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class InfoViewController: XceFactorViewController {

    @IBOutlet weak var infoHeader: UILabel!
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var dismissButton: XceFactorWideButton!
    var header: String?
    var infoText: String?
    var infoImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureViews() {
        infoImageView.isHidden = true
        //dismissButton.isHidden = true
        
        infoHeader.text = header
        infoTextLabel.text = infoText
        infoImageView.image = infoImage
    }
}
