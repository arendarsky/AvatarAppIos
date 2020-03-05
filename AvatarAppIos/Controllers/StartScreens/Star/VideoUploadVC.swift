//
//  VideoUploadVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 21.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import Alamofire

class VideoUploadVC: UIViewController {
    
    //MARK:- Properties
    var video = Video()
    lazy var player = AVPlayer(url: video.url!)
    var playerVC = AVPlayerViewController()
    
    @IBOutlet weak var uploadingVideoNotification: UILabel!
    @IBOutlet weak var uploadingVideoIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var nextStepButton: UIButton!
    
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        uploadingVideoNotification.setLabelWithAnimation(in: view, hidden: false, startDelay: 0.0)
        uploadingVideoIndicator.startAnimating()
        nextStepButton.isEnabled = false
        rangeSlider.isEnabled = false
        
        //MARK:- ❗️TODO: transfer response from upload func here ⬇️
        let headers: HTTPHeaders = [
            //"accept": "*/*",
            "Authorization": "\(authKey)"
        ]
        //MARK:- ❗️Move upload method to the WebVideo Class
        AF.upload(multipartFormData: { (multipartFormData) in
            do {
                let videoData = try Data(contentsOf: self.video.url!)
                multipartFormData.append(self.video.url!, withName: "file", fileName: "file.mov", mimeType: "video/mov")
            } catch {
                print("Couldn't get Data from URL: \(self.video.url!): \(error)")
            }
            
        }, to: "\(domain)/api/video/upload", headers: headers)
            .uploadProgress { (progress) in
                print(">>>> Upload progress: \(Int(progress.fractionCompleted * 100))%")
            }
            .responseJSON { (response) in
                print(response.request!)
                print(response.request!.allHTTPHeaderFields!)
                
                self.uploadingVideoIndicator.stopAnimating()
                self.uploadingVideoNotification.setLabelWithAnimation(in: self.view, hidden: true, startDelay: 0.0)
                self.nextStepButton.isEnabled = true
                self.rangeSlider.isEnabled = true
                print(response)
                switch response.result {
                case .success:
                    print("Alamofire session success")
                    
                case .failure(let error):
                    let alternativeTimeOutCode = 13
                    if error._code == NSURLErrorTimedOut || error._code == alternativeTimeOutCode {
                        self.showErrorConnectingToServerAlert(message: "Истекло время ожидания запроса. Повторите попытку позже")
                    }
                }
                
        }
        //if success - go to the next screen
        //performSegue(withIdentifier: "Go to Main Screens", sender: sender)
    }
    

    //MARK:- RangeSlider Value Changed
    @IBAction func rangeSliderValueChanged(_ sender: RangeSlider) {
        playerVC.player?.pause()
        if rangeSlider.upperValue == video.endTime{
            playerVC.player?.seek(to: CMTime(seconds: rangeSlider.lowerValue, preferredTimescale: 100))
            self.video.startTime = rangeSlider.lowerValue
        }else{
            playerVC.player?.seek(to: CMTime(seconds: rangeSlider.upperValue, preferredTimescale: 100))
            self.video.endTime = rangeSlider.upperValue
        }
        print("start: \(video.startTime)\nend: \(video.endTime)")
    }
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePlayer()
        configureRangeSlider()
        nextStepButton.configureHighlightedColors()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
}

private extension VideoUploadVC {
    //MARK:- Configure Player
    func configurePlayer(){
        //let player = AVPlayer(url: self.video.URL!)
        //let playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.view.frame = videoView.bounds
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 16
        playerVC.view.backgroundColor = .quaternarySystemFill
        
        //present video from specified point:
        //playerVC.player!.seek(to: CMTime(seconds: 1, preferredTimescale: 1))
        
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.addSubview(playerVC.view)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        playerVC.exitsFullScreenWhenPlaybackEnds = true
        playerVC.player?.play()
    }
    
    //MARK:- Configure Range Slider
    func configureRangeSlider(){
        if video.url != nil {
            rangeSlider.maximumValue = video.length
            if video.length > 30 {
                rangeSlider.lowerValue = video.length / 2 - 15
                rangeSlider.upperValue = video.length / 2 + 15
            } else {
                rangeSlider.lowerValue = 0
                rangeSlider.upperValue = video.length
            }
            video.startTime = rangeSlider.lowerValue
            video.endTime = rangeSlider.upperValue
            //print(rangeSlider.maximumValue)
        }
    }
}
