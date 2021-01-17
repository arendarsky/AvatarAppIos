//
//MARK:  VideoPickVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 20.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Amplitude

class VideoPickVC: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var nextStepButton: UIBarButtonItem!

    @IBOutlet private weak var addVideoButton: UIButton!

    @IBOutlet private weak var pickVideoStatus: UILabel!
    @IBOutlet private weak var addVideoHeader: UILabel!
    @IBOutlet private weak var descriptionHeader: UILabel!
    @IBOutlet private weak var descriptionPlaceholder: UILabel!
    @IBOutlet private weak var descriptionHint: UILabel!
    @IBOutlet private weak var symbolCounter: UILabel!

    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var contactField: UITextField!

    @IBOutlet private weak var contactBorder: UIView!
        //@IBOutlet weak var descriptionBorder: UIView!

    // MARK: - Public Properties
    
    let symbolLimit = 150
    var pickedVideo = Video()
    var shouldHideViews = false
    var isProfileInitiated = false
    var isCastingInitiated = false
    var shouldHideBackButton = true
    var navBarImageView: UIImageView?
    var navBarBlurView: UIView?

    // MARK: - Private Properties

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private var alertFactory: AlertFactoryProtocol?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Инициализирвоать в билдере, при переписи на MVP поправить:
        alertFactory = AlertFactory(viewController: self)

        configureCustomNavBar() { imgView, blurView  in
            self.navBarImageView = imgView
            self.navBarBlurView = blurView
        }
        configureViews()
        //descriptionView.addBorders(.bottom, color: .placeholderText)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nextStepButton.isEnabled = false
        nextStepButton.isEnabled = true
    }
    
    // MARK: - Overrides

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! VideoUploadVC
        destinationVC.video = pickedVideo
        destinationVC.profileDescription = descriptionView.text
        destinationVC.isProfileInitiated = isProfileInitiated
        destinationVC.isCastingInitiated = isCastingInitiated
    }

    // MARK: - IBActions
    // TODO: - IBActions -> Actions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    /// UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
    
    @IBAction private func addVideoButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        // Button Pressed Log
        Amplitude.instance()?.logEvent("newvideo_squared_button_tapped")
        presentAlertAndPickVideo()
    }
    
    /// Next Step Button Pressed
    @IBAction private func nextStepButtonPressed(_ sender: Any) {
        if self.pickedVideo.length < 0 {
            alertFactory?.showAlert(type: .videoNotAdded)
       /* } else if self.pickedVideo.length > 30 {
            showVideoErrorAlert(with: "Длина видео превышает 30 секунд")*/
        } else if descriptionView.text.count > symbolLimit {
            alertFactory?.showAlert(type: .descriptionIsTooLong)
        } else {
            performSegue(withIdentifier: "Show VideoUploadVC", sender: sender)
        }
    }

    // MARK: - Public Methods

}

private extension VideoPickVC {

    /// Pick Video From Gallery
    func presentAlertAndPickVideo(){
        //let modalPresentationStyle: UIModalPresentationStyle = isProfileInitiated ? .overFullScreen : .overCurrentContext
        showMediaPickAlert(mediaTypes: [kUTTypeMovie], delegate: self)
    }

    func configureViews() {
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
        
        descriptionView.delegate = self
        contactField.delegate = self
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGeture(_ :)))
        view.addGestureRecognizer(panRecognizer)
    }
    
    //MARK: - Actions

    @objc func handlePanGeture(_ sender: UIPanGestureRecognizer) {
        if isCastingInitiated {
            let translation = sender.translation(in: view)
            let alpha: CGFloat = translation.y > 50 ? 0 : 1
            UIView.animate(withDuration: alpha == 1 ? 0.2 : 0.0) {
                self.navBarImageView?.alpha = alpha
                self.navBarBlurView?.alpha = alpha
            }
            navigationController?.view.transform = CGAffineTransform(translationX: 0, y: translation.y > 50 ? translation.y : 0)
            if sender.state == .ended {
                //MARK:- Dismiss vc on swipe
                if translation.y > 140 {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [.curveEaseIn], animations: {
                        self.navigationController?.view.transform = .identity
                        self.navBarImageView?.alpha = 1
                        self.navBarBlurView?.alpha = 1
                    }, completion: nil)
                }
            }
        }
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
        
        //VideoHelper.encodeVideo(at: url) { (encodedUrl, error) in

           /* if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.pickVideoStatus.isHidden = false
                    self.pickVideoStatus.setViewWithAnimation(in: self.view, hidden: true, startDelay: 2.0)
                    self.dismiss(animated: true) {
                        self.pickVideoStatus.text = "☓ Выберите ещё раз"
                        self.pickVideoStatus.textColor = .systemRed
                        self.showVideoErrorAlert(with: "Произошла ошибка")
                    }
                }
                
            }
            else if let resultUrl = encodedUrl {*/
                self.pickedVideo.url = url //resultUrl
                let asset = AVAsset(url: url) //resultUrl
                self.pickedVideo.length = Double(asset.duration.value) / Double(asset.duration.timescale)
                print("Video length: \(self.pickedVideo.length) second(s)")
                
                DispatchQueue.main.async {
                    self.pickVideoStatus.isHidden = false
                    self.pickVideoStatus.setViewWithAnimation(in: self.view, hidden: true, startDelay: 2.0)
                    self.dismiss(animated: true) {
                        self.pickVideoStatus.text = "✓ Успешно"
                        self.pickVideoStatus.textColor = .systemGreen
                        VideoHelper.createVideoThumbnail(from: self.pickedVideo.url) { (image) in
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
                
            //}
            
        //}
    }
}

// MARK: - UINavigationControllerDelegate

extension VideoPickVC: UINavigationControllerDelegate {}


// MARK: - Text View Delegate

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


// MARK: - UI Text Field Delegate

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
