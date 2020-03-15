//
//  ProfileVideoView.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit

class ProfileVideoView: UIView {
    
    //MARK:- Properties
    var video = Video()
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    //MARK:- Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        //play video on full screen
        
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        
    }
    
}

private extension ProfileVideoView {
    private func configureView() {
        playButton.layer.cornerRadius = playButton.frame.width / 2
    }

    private func xibSetup() {
        Bundle.main.loadNibNamed("ProfileVideoView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
