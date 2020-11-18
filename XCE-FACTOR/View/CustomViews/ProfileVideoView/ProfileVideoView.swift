//
//MARK:  ProfileVideoView.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import NVActivityIndicatorView

class ProfileVideoView: UIView {
    
    //MARK: - Properties

    weak var delegate: ProfileVideoViewDelegate?
    
    var video = Video()
    var index: Int = 0

    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    
    //MARK: - Lifecycle

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
    
    // MARK: - IBActions

    @IBAction func playButtonPressed(_ sender: Any) {
        delegate?.playButtonPressed(at: index, video: video)
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        delegate?.optionsButtonPressed(at: index, video: video)
    }
    
    //MARK: - Public Methods

    func addContextMenu(delegate: UIContextMenuInteractionDelegate) {
        let interaction = UIContextMenuInteraction(delegate: delegate)
        self.addInteraction(interaction)
    }
    
}

// MARK: - Private Methods

private extension ProfileVideoView {

    func configureView() {
        playButton.layer.cornerRadius = playButton.frame.width / 2
        
        if #available(iOS 13.0, *) {} else {
            playButton.setImage(IconsManager.getIcon(.playSmall), for: .normal)
            optionsButton.setImage(IconsManager.getIcon(.optionDotsSmall), for: .normal)
        }
        
        //self.addContextMenu(delegate: self)
    }

    func xibSetup() {
        Bundle.main.loadNibNamed("ProfileVideoView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

// MARK: - Context Menu Interaction Delegate

extension ProfileVideoView: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let copyLink = UIAction(title: "Скопировать ссылку",
                                    image: UIImage(systemName: "doc.on.doc")) { action in
                self.delegate?.copyLinkButtonPressed(at: self.index, video: self.video)
            }
            
            let shareVideo = UIAction(title: "Поделиться видео",
                                      image: UIImage(systemName: "square.and.arrow.up")) { action in
                self.delegate?.shareButtonPreseed(at: self.index, video: self.video)
            }

            return UIMenu(title: "", children: [shareVideo, copyLink])
        }
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                                animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            self.delegate?.playButtonPressed(at: self.index, video: self.video)
        }
    }
    
}
