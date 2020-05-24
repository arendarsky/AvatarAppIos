//
//  ProfileVideoView.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import NVActivityIndicatorView

protocol ProfileVideoViewDelegate: class {
    func playButtonPressed(at index: Int, video: Video)
    func optionsButtonPressed(at index: Int, video: Video)
    func copyLinkButtonPressed(at index: Int, video: Video)
    func shareButtonPreseed(at index: Int, video: Video)
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
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    
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
    
    //MARK:- Add Context Menu
    func addContextMenu(delegate: UIContextMenuInteractionDelegate) {
        let interaction = UIContextMenuInteraction(delegate: delegate)
        self.addInteraction(interaction)
    }
    
}

private extension ProfileVideoView {
    //MARK:- Configure View
    private func configureView() {
        playButton.layer.cornerRadius = playButton.frame.width / 2
        
        if #available(iOS 13.0, *) {} else {
            playButton.setImage(IconsManager.getIcon(.playSmall), for: .normal)
            optionsButton.setImage(IconsManager.getIcon(.optionDotsSmall), for: .normal)
        }
        
        self.addContextMenu(delegate: self)
    }

    private func xibSetup() {
        Bundle.main.loadNibNamed("ProfileVideoView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

//MARK:- Context Menu Delegate
///
extension ProfileVideoView: UIContextMenuInteractionDelegate {
    
    //MARK:- Configure Menu
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
            
            let copyLink = UIAction(title: "Скопировать ссылку", image: UIImage(systemName: "doc.on.doc")) { (action) in
                self.delegate?.copyLinkButtonPressed(at: self.index, video: self.video)
            }
            
            let shareVideo = UIAction(title: "Поделиться видео", image: UIImage(systemName: "square.and.arrow.up")) { (action) in
                self.delegate?.shareButtonPreseed(at: self.index, video: self.video)
            }
            return UIMenu(title: "", children: [shareVideo, copyLink])
            
        }
        return config
    }
    
    //MARK:- Perform Preview Action
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.delegate?.playButtonPressed(at: self.index, video: self.video)
        }
    }
    
}
