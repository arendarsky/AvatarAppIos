//
//  ProfileVideoView.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit

protocol ProfileVideoViewDelegate: class {
    func playButtonPressed(at index: Int, video: Video)
    func optionsButtonPressed(at index: Int, video: Video)
}

class ProfileVideoView: UIView {
    
    //MARK:- Properties
    weak var delegate: ProfileVideoViewDelegate?
    
    var video = Video()
    var index: Int = 0
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    
    //MARK:- Play Video Button Pressed
    @IBAction func playButtonPressed(_ sender: Any) {
        delegate?.playButtonPressed(at: index, video: video)
                
    }
    
    //MARK:- Options Button Pressed
    @IBAction func optionsButtonPressed(_ sender: Any) {
        delegate?.optionsButtonPressed(at: index, video: video)
    }
    
    func showActivityIndicator(duration: Double) {
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.activityIndicator.stopAnimating()
        }
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
