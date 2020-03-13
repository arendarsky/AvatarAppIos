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
    @IBOutlet private weak var pickVideoStatus: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var descriptionPlaceholder: UILabel!
    @IBOutlet weak var descriptionBorder: UIView!
    
    @IBOutlet weak var contactField: UITextField!
    @IBOutlet weak var contactBorder: UIView!
    
    var uploadedVideo = Video()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideoButton()
        
        //descriptionView.addBorders(color: .placeholderText, border: .bottom)
       
    //descriptionView.translatesAutoresizingMaskIntoConstraints = true
        descriptionView.delegate = self
        contactField.delegate = self
       // addTextViewBottomLine()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
        
    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! VideoUploadVC
        destinationVC.video = uploadedVideo
    }
    
    @IBAction private func addVideoButtonPressed(_ sender: UIButton) {
        presentAlertAndPickVideo()
    }
    
    //MARK:- Next Step Button Pressed
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        if self.uploadedVideo.length < 0 {
            showVideoErrorAlert(with: "Видео не добавлено")
       /* } else if self.uploadedVideo.length > 30 {
            showVideoErrorAlert(with: "Длина видео превышает 30 секунд")*/
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
        let galleryButton = UIAlertAction(title: "Выбрать из фотопленки", style: .default) { (action) in
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }
        let cancelBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(cameraBtn)
        alert.addAction(galleryButton)
        alert.addAction(cancelBtn)
        
        present(alert, animated: true, completion: nil)
    }
}

extension VideoPickVC {
    //MARK:- Configure addVideoButton
    func configureVideoButton(){
        addVideoButton.setBackgroundColor(.lightGray, forState: .highlighted)
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
        
        VideoHelper.encodeVideo(at: url) { (encodedUrl, error) in
            

            if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.pickVideoStatus.isHidden = false
                    self.pickVideoStatus.setLabelWithAnimation(in: self.view, hidden: true, startDelay: 2.0)
                    self.dismiss(animated: true) {
                        self.pickVideoStatus.text = "☓ Выберите ещё раз"
                        self.pickVideoStatus.textColor = .systemRed
                        self.showVideoErrorAlert(with: "Произошла ошибка")
                    }
                }
                
            }
            else if let resultUrl = encodedUrl {
                self.uploadedVideo.url = resultUrl
                let asset = AVAsset(url: resultUrl)
                self.uploadedVideo.length = Double(asset.duration.value) / Double(asset.duration.timescale)
                print("Video length: \(self.uploadedVideo.length) second(s)")
                
                DispatchQueue.main.async {
                    self.pickVideoStatus.isHidden = false
                    self.pickVideoStatus.setLabelWithAnimation(in: self.view, hidden: true, startDelay: 2.0)
                    self.dismiss(animated: true) {
                        self.pickVideoStatus.text = "✓ Успешно"
                        self.pickVideoStatus.textColor = .systemGreen
                    }
                }
                
            }
            
        }
        
    //Closes gallery after pressing 'Выбрать' ('Choose')
        //dismiss(animated: true) {
            //MARK:- Can Manage Video Length Here
            //or possibly inside the image picker controller
            
            /*if self.uploadedVideo.length > 30.99 {
                
                self.pickVideoStatus.text = "☓ Выберите ещё раз"
                self.pickVideoStatus.textColor = .systemRed
                self.showVideoErrorAlert(with: "Длина видео превышает 30 секунд")
 
            } else {*/
                //self.pickVideoStatus.text = "✓ Успешно"
                //self.pickVideoStatus.textColor = .systemGreen
            
                //⬇️ proceed immediately to the next view if successful
                //self.performSegue(withIdentifier: "Show VideoUploadVC", sender: nil)
           // }
        //}
    }
}
// MARK: - UINavigationControllerDelegate
extension VideoPickVC: UINavigationControllerDelegate {
}

extension VideoPickVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        //descriptionPlaceholder.isHidden = true
        descriptionBorder.backgroundColor = .systemBlue
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0 {
            descriptionPlaceholder.isHidden = false
            descriptionBorder.backgroundColor = .placeholderText
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = textView.text.count != 0
//        if textView.frame.height < 90 {
//            let fixedWidth = textView.frame.size.width
//            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//            var newFrame = textView.frame
//            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//            textView.frame = newFrame
//
//
//        }
    }
}

extension VideoPickVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        contactBorder.backgroundColor = .systemBlue
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            contactBorder.backgroundColor = .placeholderText
        }
    }
}

extension UITextView {
    enum BorderType {
        case top
        case bottom
        case both
    }
    
    func addBorders(color: UIColor, border: BorderType) {
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = color.cgColor
        bottomBorder.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        bottomBorder.name = "BottomBorder"
        
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        topBorder.name = "TopBorder"
        
        switch border {
        case .both:
            layer.addSublayer(bottomBorder)
            layer.addSublayer(topBorder)
        case .top:
            layer.addSublayer(topBorder)
        case .bottom:
            layer.addSublayer(bottomBorder)
        }
    }
}
