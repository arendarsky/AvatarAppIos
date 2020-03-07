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
    private lazy var player = AVPlayer(url: video.url!)
    private var playerVC = AVPlayerViewController()
    private var spinner: UIActivityIndicatorView?
    private var videoObserver: Any?
    
    @IBOutlet private weak var uploadingVideoNotification: UILabel!
    @IBOutlet private weak var uploadProgressView: UIProgressView!
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var videoRangeSlider: ABVideoRangeSlider!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet var nextStepButton: UIBarButtonItem!
    
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideoRangeSlider()
        configurePlayer()

        //addObserver(self, forKeyPath: video.name, options: .new, context: nil)
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        controlsView.isHidden = false
        videoRangeSlider.isHidden = false
        addVideoObserver()
    }
    
    //MARK:- • Did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.all)
        controlsView.isHidden = true
        videoRangeSlider.isHidden = true
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        removeVideoObserver()
    }
    
    //MARK:- Handle Play/Pause
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if playerVC.player?.timeControlStatus == .playing {
            playerVC.player?.pause()
            
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            playerVC.player?.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)         }
    }
    
    //MARK:- Next Step Button Pressed
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        playerVC.player?.pause()
        uploadingVideoNotification.setLabelWithAnimation(in: view, hidden: false)
        uploadProgressView.setViewWithAnimation(in: view, hidden: false)
        enableLoadingIndicator()
        //rangeSlider.isEnabled = false
        

        let headers: HTTPHeaders = [
            //"accept": "*/*",
            "Authorization": "\(authKey)"
        ]
        //MARK:- ❗️Move upload method to the WebVideo Class
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(self.video.url!, withName: "file", fileName: "file.mov", mimeType: "video/mov")
        }, to: "\(domain)/api/video/upload", headers: headers)
            
            .uploadProgress { (progress) in
                print(">>>> Upload progress: \(Int(progress.fractionCompleted * 100))%")
                self.uploadProgressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
            .response { (response) in
                print(response.request!)
                print(response.request!.allHTTPHeaderFields!)
                
                self.uploadingVideoNotification.setLabelWithAnimation(in: self.view, hidden: true)
                self.uploadProgressView.setViewWithAnimation(in: self.view, hidden: true)
                
                switch response.result {
                case .success:
                    print("Alamofire session success")
                    
                case .failure(let error):
                    let alternativeTimeOutCode = 13
                    if error._code == NSURLErrorTimedOut || error._code == alternativeTimeOutCode {
                        self.showErrorConnectingToServerAlert(message: "Истекло время ожидания запроса. Повторите попытку позже")
                    } else {
                        self.showErrorConnectingToServerAlert()
                    }
                }
                
                if let data = response.data {
                    if let videoInfo = try? JSONDecoder().decode(VideoWebData.self, from: data) {
                        self.video.name = videoInfo.name
                        
    //MARK:- Add an observer for video.name value and remove this method from the closure ⬇️
                        
                        WebVideo.setInterval(videoName: self.video.name, startTime: self.video.startTime, endTime: self.video.endTime) { serverResult in
                            switch serverResult {
                            case .error(let error):
                                print(error.localizedDescription)
                                self.showErrorConnectingToServerAlert()
                            case .results(let responseCode):
                                if responseCode != 200 {
                                    self.showErrorConnectingToServerAlert(title: "Не удалось отправить видео в данный момент")
                                } else {
                                    self.disableLoadingIndicator()
                                    self.nextStepButton.isEnabled = false
                                    //show successfully uploaded notification
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.nextStepButton.isEnabled = true
                                        self.dismiss(animated: true, completion: nil)
                                        self.presentNewRootViewController()
                                    }
                                }
                            }
                        }
                    } else {
                        self.showErrorConnectingToServerAlert()
                    }
                } else {
                    self.showErrorConnectingToServerAlert()
                }
        }
        
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
        videoView.insertSubview(playerVC.view, belowSubview: controlsView)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        playerVC.exitsFullScreenWhenPlaybackEnds = true
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 600))
        playerVC.player?.play()
    }
    
    
    //MARK:- Remove Video Time Observer
    private func removeVideoObserver() {
        if let observer = self.videoObserver {
            //removing time obse
            playerVC.player?.removeTimeObserver(observer)
            videoObserver = nil
        }
    }
    
    //MARK:- Add Video Time Observer
    private func addVideoObserver() {
        removeVideoObserver()
        
        let interval = CMTimeMake(value: 1, timescale: 600)
        videoObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            self?.videoRangeSlider.updateProgressIndicator(seconds: currentTime)
        }
    }
    
    
    //MARK:- Configure Video Range Slider
    func configureVideoRangeSlider() {
        if video.length > 30 {
            video.startTime = video.length / 2 - 15
            video.endTime = video.length / 2 + 15
        } else {
            video.startTime = 0
            video.endTime = video.length
        }
        videoRangeSlider.setVideoURL(videoURL: video.url!)
        videoRangeSlider.delegate = self
        videoRangeSlider.minSpace = 4.0
        videoRangeSlider.maxSpace = 30.5
        videoRangeSlider.setStartPosition(seconds: Float(video.startTime))
        videoRangeSlider.setEndPosition(seconds: Float(video.endTime))
        videoRangeSlider.progressPercentage = videoRangeSlider.startPercentage
        videoRangeSlider.isProgressIndicatorSticky = true
        
        videoRangeSlider.startTimeView.setCustomView(backgroundColor: .black, textColor: .white)
        videoRangeSlider.endTimeView.setCustomView(backgroundColor: .black, textColor: .white)
        
        videoRangeSlider.startTimeView.isHidden = true
        videoRangeSlider.endTimeView.isHidden = true
        
    }
    
    //MARK:- Bar Button Loading Indicator
    private func enableLoadingIndicator(){
        if spinner == nil {
            spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        }
        let barButton = UIBarButtonItem(customView: spinner!)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        spinner!.startAnimating()
    }
    
    private func disableLoadingIndicator(){
        spinner?.stopAnimating()
        self.navigationItem.setRightBarButton(nextStepButton, animated: true)
    }
    
    private func secondsFromValue(value: CGFloat) -> Float64{
        return self.videoRangeSlider.duration * Float64((value / 100))
    }
}


//MARK:- Range Slider Delegate
extension VideoUploadVC: ABVideoRangeSliderDelegate {
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        video.startTime = startTime
        video.endTime = endTime
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        playerVC.player?.seek(to: CMTime(seconds: position, preferredTimescale: 600))
    }
    
    func sliderGesturesBegan() {
        let duration = 0.1
        videoRangeSlider.startTimeView.setViewWithAnimation(in: videoView, hidden: false, startDelay: 0.0, duration: duration)
        videoRangeSlider.endTimeView.setViewWithAnimation(in: videoView, hidden: false, startDelay: 0.0, duration: duration)
    }
    
    func sliderGesturesEnded() {
        let duration = 0.1
        videoRangeSlider.startTimeView.setViewWithAnimation(in: videoView, hidden: true, startDelay: 0.0, duration: duration)
        videoRangeSlider.endTimeView.setViewWithAnimation(in: videoView, hidden: true, startDelay: 0.0, duration: duration)
    }
    
}


private extension ABTimeView {
    //MARK:- set Custom Time View
    func setCustomView(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundView.backgroundColor = backgroundColor
        self.backgroundView.alpha = 0.5
        self.backgroundView.layer.cornerRadius = 8.0
        self.timeLabel.textColor = textColor
        self.marginLeft = 0.0
        self.marginRight = 0.0
    }
}