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
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nextStepButton: UIBarButtonItem!
    
    @IBOutlet weak var descriptionHeader: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var descriptionPlaceholder: UILabel!
    @IBOutlet weak var descriptionHint: UILabel!
    @IBOutlet weak var symbolCounter: UILabel!
    //@IBOutlet weak var descriptionBorder: UIView!
    
    @IBOutlet weak var contactField: UITextField!
    @IBOutlet weak var contactBorder: UIView!
    
    let symbolLimit = 150
    var pickedVideo = Video()
    var shouldHideViews = false
    var isProfileInitiated = false
    var shouldHideBackButton = true
    
    //MARK:- Lifecycle
    ///
    ///
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldHideViews || isProfileInitiated {
            descriptionPlaceholder.isHidden = true
            descriptionView.isHidden = true
            symbolCounter.isHidden = true
            descriptionHeader.isHidden = true
            descriptionHint.isHidden = true
            if shouldHideBackButton {
                backButton.isEnabled = false
                backButton.tintColor = .clear
            }
        }
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        
        self.configureCustomNavBar()
        configureViews()
        
        //descriptionView.addBorders(color: .placeholderText, border: .bottom)
       
        descriptionView.delegate = self
        contactField.delegate = self
    }
    
    //MARK:- • Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextStepButton.isEnabled = true
        nextStepButton.tintColor = .white
    }
    
    //MARK:- Dismiss the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! VideoUploadVC
        destinationVC.video = pickedVideo
        destinationVC.profileDescription = descriptionView.text
        destinationVC.isProfileInitiated = isProfileInitiated
    }
    
    //MARK:- UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    //MARK:- UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
    
    @IBAction private func addVideoButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        presentAlertAndPickVideo()
    }
    
    //MARK:- Next Step Button Pressed
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        if self.pickedVideo.length < 0 {
            showVideoErrorAlert(with: "Видео не добавлено")
       /* } else if self.pickedVideo.length > 30 {
            showVideoErrorAlert(with: "Длина видео превышает 30 секунд")*/
        } else if descriptionView.text.count > symbolLimit {
            showIncorrectUserInputAlert(title: "Описание слишком длинное", message: "")
        } else {
            performSegue(withIdentifier: "Show VideoUploadVC", sender: sender)
        }
    }
    
    
 //MARK:- Pick Video From Gallery
    func presentAlertAndPickVideo(){
        showMediaPickAlert(mediaTypes: [kUTTypeMovie], delegate: self)
    }
}

extension VideoPickVC {
    //MARK:- Configure Views
    func configureViews() {
        addVideoButton.addGradient(
            firstColor: UIColor(red: 0.879, green: 0.048, blue: 0.864, alpha: 0.3),
            secondColor: UIColor(red: 0.667, green: 0.239, blue: 0.984, alpha: 0.3),
            transform: CGAffineTransform(a: 1, b: 0, c: 0, d: 38.94, tx: 0, ty: -18.97)
        )
        addVideoButton.backgroundColor = .black
        
        descriptionView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        symbolCounter.text = "\(descriptionView.text.count)/\(symbolLimit)"
        
        addVideoButton.layoutIfNeeded()
        addVideoButton.subviews.first?.contentMode = .scaleAspectFit
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
                self.pickedVideo.url = resultUrl
                let asset = AVAsset(url: resultUrl)
                self.pickedVideo.length = Double(asset.duration.value) / Double(asset.duration.timescale)
                print("Video length: \(self.pickedVideo.length) second(s)")
                
                DispatchQueue.main.async {
                    self.pickVideoStatus.isHidden = false
                    self.pickVideoStatus.setLabelWithAnimation(in: self.view, hidden: true, startDelay: 2.0)
                    self.dismiss(animated: true) {
                        self.pickVideoStatus.text = "✓ Успешно"
                        self.pickVideoStatus.textColor = .systemGreen
                        VideoHelper.createVideoThumbnailFromUrl(videoUrl: self.pickedVideo.url) { (image) in
                            self.addVideoButton.setBackgroundImage(image, for: .normal)
                            self.addVideoButton.layoutIfNeeded()
                            self.addVideoButton.subviews.first?.contentMode = .scaleAspectFit
                        }
                        //MARK:-⬇️ auto show next view
                        if !(self.isProfileInitiated || self.shouldHideViews) {
                            self.performSegue(withIdentifier: "Show VideoUploadVC", sender: nil)
                        }
                    }
                }
                
            }
            
        }
    }
}
// MARK: - UINavigationControllerDelegate
extension VideoPickVC: UINavigationControllerDelegate {
}


//MARK:- Text View Delegate
extension VideoPickVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        //descriptionPlaceholder.isHidden = true
        //descriptionBorder.backgroundColor = .systemBlue
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0 {
            descriptionPlaceholder.isHidden = false
            //descriptionBorder.backgroundColor = .placeholderText
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        symbolCounter.text = "\(textView.text.count)/\(symbolLimit)"
        descriptionPlaceholder.isHidden = textView.text.count != 0
        if textView.text.count > symbolLimit {
            textView.borderColorV = .systemRed
            symbolCounter.textColor = .systemRed
        } else {
            if #available(iOS 13.0, *) {
                textView.borderColorV = .placeholderText
                symbolCounter.textColor = .placeholderText
            } else {
                textView.borderColorV = .lightGray
                symbolCounter.textColor = .lightGray
            }
        }
        
        ///dynamically resize textView height:
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


//MARK:- Text Field Delegate
extension VideoPickVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        contactBorder.backgroundColor = .systemBlue
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            if #available(iOS 13.0, *) {
                contactBorder.backgroundColor = .placeholderText
            } else {
                contactBorder.backgroundColor = .lightGray
            }
        }
    }
}
