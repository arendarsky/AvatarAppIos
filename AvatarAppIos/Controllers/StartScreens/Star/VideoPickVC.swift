//
//  VideoPickVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 20.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

class VideoPickVC: UIViewController {
    
    //MARK:- Properties
    @IBOutlet private weak var addVideoButton: UIButton!
    @IBOutlet private weak var uploadStatus: UILabel!
    var uploadedVideo = Video()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideoButton()
    }
    
    //MARK:- Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! VideoUploadVC
        destinationVC.video = uploadedVideo
    }
    
    @IBAction private func addVideoButtonPressed(_ sender: UIButton) {
        presentAlertAndPickVideo()
    }
    
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        if self.uploadedVideo.length < 0 {
            showVideoLengthWarningAlert(with: "Видео не добавлено")
       /* } else if self.uploadedVideo.length > 30 {
            showVideoLengthWarningAlert(with: "Длина видео превышает 30 секунд")*/
        } else {
            performSegue(withIdentifier: "Show VideoUploadVC", sender: sender)
        }
    }
    
    
 //MARK:- Pick Video From Gallery
    func presentAlertAndPickVideo(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraBtn = UIAlertAction(title: "Снять на камеру", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
        }
        let galleryButton = UIAlertAction(title: "Выбрать из галереи", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }
        let cancelBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(cameraBtn)
        alert.addAction(galleryButton)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK:- Configure addVideoButton
extension VideoPickVC {
    func configureVideoButton(){
        addVideoButton.alignImageAndTitleVertically()
        addVideoButton.setBackgroundColor(.lightGray, forState: .highlighted)
        addVideoButton.setTitleColor(.darkGray, for: .highlighted)
        addVideoButton.titleLabel!.textAlignment = .center
    }
}

// MARK: - UIImagePickerControllerDelegate
extension VideoPickVC: UIImagePickerControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        else { return }
        self.uploadedVideo.url = url
        let asset = AVAsset(url: url)
        self.uploadedVideo.length = Double(asset.duration.value) / Double(asset.duration.timescale)
        debugPrint("Video length: \(self.uploadedVideo.length) second(s)")
        
        
    //Closes gallery after pressing 'Выбрать' ('Choose')
        dismiss(animated: true) {
            //MARK:- Can Manage Video Length Here
            //or possibly in the image picker controller
            /*if self.uploadedVideo.length > 30.99 {
                
                self.uploadStatus.text = "☓ Выберите ещё раз"
                self.uploadStatus.textColor = .systemRed
                self.showVideoLengthWarningAlert(with: "Длина видео превышает 30 секунд")
 
            } else {*/
                self.uploadStatus.text = "✓ Успешно"
                self.uploadStatus.textColor = .systemGreen
            
                //⬇️ proceed immediately to the next view if successful
                self.performSegue(withIdentifier: "Show VideoUploadVC", sender: nil)
           // }
            self.uploadStatus.isHidden = false
            self.uploadStatus.setLabelWithAnimation(in: self.view, hidden: true, startDelay: 1.0)
        }
    }
}
// MARK: - UINavigationControllerDelegate
extension VideoPickVC: UINavigationControllerDelegate {
}
