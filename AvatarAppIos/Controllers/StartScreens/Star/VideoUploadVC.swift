//
//  VideoUploadVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 20.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

class VideoUploadVC: UIViewController {
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Show VideoCropVC", sender: sender)
    }
    @IBOutlet weak var addVideoButton: UIButton!
    @IBAction func addVideoButtonPressed(_ sender: UIButton) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideoButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //should transfer the uploaded video to the next VC here
    }
}

//MARK:- Configure addVideoButton
extension VideoUploadVC {
    func configureVideoButton(){
        addVideoButton.alignImageAndTitleVertically()
        addVideoButton.setBackgroundColor(color: .lightGray, forState: .highlighted)
        addVideoButton.setTitleColor(.darkGray, for: .highlighted)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension VideoUploadVC: UIImagePickerControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
      else { return }
    
    dismiss(animated: true) {
      let player = AVPlayer(url: url)
      let vcPlayer = AVPlayerViewController()
      vcPlayer.player = player
      self.present(vcPlayer, animated: true, completion: nil)
    }
  }
}

// MARK: - UINavigationControllerDelegate
extension VideoUploadVC: UINavigationControllerDelegate {
}


//MARK:- Align Button Image And Title Vertically
private extension UIButton {
    func alignImageAndTitleVertically(padding: CGFloat = 6.0) {
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding

        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )

        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }

}
