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
let serverPath = ""

class VideoUploadVC: UIViewController {
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        if self.uploadedVideo.length < 0 {
            showLengthWarningAlert(with: "Видео не добавлено")
        } else if self.uploadedVideo.length > 30 {
            showLengthWarningAlert(with: "Длина видео превышает 30 секунд")
        } else {
            performSegue(withIdentifier: "Show VideoCropVC", sender: sender)
        }
    }
    @IBOutlet weak var addVideoButton: UIButton!
    @IBAction func addVideoButtonPressed(_ sender: UIButton) {
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
    }
    @IBOutlet weak var uploadStatus: UILabel!
    var uploadedVideo = Video()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideoButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! VideoCropVC
        destinationVC.video = uploadedVideo
    }
}

//MARK:- Configure addVideoButton
extension VideoUploadVC {
    func configureVideoButton(){
        addVideoButton.alignImageAndTitleVertically()
        addVideoButton.setBackgroundColor(.lightGray, forState: .highlighted)
        addVideoButton.setTitleColor(.darkGray, for: .highlighted)
        addVideoButton.titleLabel!.textAlignment = .center
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
        self.uploadedVideo.URL = url
        let asset = AVAsset(url: url)
        self.uploadedVideo.length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("Video length: \(self.uploadedVideo.length) second(s)")
        
        
    //Closes gallery after pressing 'Выбрать' ('Choose')
        dismiss(animated: true) {
            if self.uploadedVideo.length > 30.99 {
                self.uploadStatus.text = "☓ Выберите ещё раз"
                self.uploadStatus.textColor = .systemRed
                self.showLengthWarningAlert(with: "Длина видео превышает 30 секунд")
            } else {
                self.uploadStatus.text = "✓ Успешно"
                self.uploadStatus.textColor = .systemGreen
                //proceed immediately to the next view if successful
                self.performSegue(withIdentifier: "Show VideoCropVC", sender: nil)
            }
            self.uploadStatus.isHidden = false
            self.uploadStatus.setLabelWithAnimation(in: self.view, hidden: true, delay: 2)
        }
    }
}
// MARK: - UINavigationControllerDelegate
extension VideoUploadVC: UINavigationControllerDelegate {
}


//MARK:- Align Button Image And Title Vertically
private extension UIButton {
    func alignImageAndTitleVertically(padding: CGFloat = 10.0) {
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
