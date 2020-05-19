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
    var infoText: NSMutableAttributedString?
    var infoImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureViews() {
        view.backgroundColor = .clear//UIColor.systemPurple.withAlphaComponent(0.3)//UIColor.darkGray.withAlphaComponent(0.5)
        view.addBlur(style: .regular)
        
        infoHeader.text = header
        infoTextLabel.attributedText = infoText
        infoImageView.image = infoImage
    }
}
