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
    var isProfileInitiated = false
    var profileDescription = ""
    
    private lazy var player = AVPlayer(url: video.url!)
    private var playerVC = AVPlayerViewController()
    private var spinner: UIActivityIndicatorView?
    private var videoObserver: Any?
    private var videoDidEndPlayingObserver: Any?
    
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
        self.configureCustomNavBar()
        handlePossibleSoundError()
        configureVideoRangeSlider()
        configurePlayer()

        //addObserver(self, forKeyPath: video.name, options: .new, context: nil)
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        controlsView.isHidden = false
        videoRangeSlider.isHidden = false
        addVideoObservers()
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
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    //MARK:- Next Step Button Pressed
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        playerVC.player?.pause()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        uploadingVideoNotification.setLabelWithAnimation(in: view, hidden: false)
        uploadProgressView.setViewWithAnimation(in: view, hidden: false)
        enableLoadingIndicator()
        //rangeSlider.isEnabled = false
        
        if profileDescription != "" {
            Profile.setDescription(newDescription: profileDescription) { serverResult in
                switch serverResult {
                case.error(let error):
                    print("Error setting description: \(error)")
                case.results(let responseCode):
                    print("response code: \(responseCode)")
                }
            }
        }
        

        let headers: HTTPHeaders = [
            //"accept": "*/*",
            "Authorization": "\(Globals.user.token)"
        ]
        //MARK:- ❗️❗️❗️Move upload method to the WebVideo Class
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(self.video.url!, withName: "file", fileName: "file.mp4", mimeType: "video/mp4")
        }, to: "\(Globals.domain)/api/video/upload", headers: headers)
            
            .uploadProgress { (progress) in
                print(">>>> Upload progress: \(Int(progress.fractionCompleted * 100))%")
                self.uploadProgressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
            .response { (response) in
                print(response.request!)
                print(response.request!.allHTTPHeaderFields!)
                
                switch response.result {
                case .success:
                    print("Alamofire session success")
                    print("upload request status code:", response.response!.statusCode)
                    if response.response!.statusCode != 200 {
                        self.showErrorConnectingToServerAlert()
                        return
                    }
                case .failure(let error):
                    print("Alamofire session failure")
                    let alternativeTimeOutCode = 13
                    if error._code == NSURLErrorTimedOut || error._code == alternativeTimeOutCode {
                        self.showErrorConnectingToServerAlert(message: "Истекло время ожидания запроса. Повторите попытку позже")
                        self.disableLoadingIndicator()
                        self.nextStepButton.isEnabled = true
                    } else {
                        self.showErrorConnectingToServerAlert()
                        return
                    }
                }
                
                if Globals.user.videosCount == nil {
                    Globals.user.videosCount = 1
                } else {
                    Globals.user.videosCount! += 1
                }
                if let data = response.data {
                    if let videoInfo = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                        self.video.name = videoInfo as! String
                        print("Response video name: \(self.video.name)")
                        print("Now setting start time: \(self.video.startTime) and end time: \(self.video.endTime)")
                        
                        //MARK:- Setting Interval
                        
                        WebVideo.setInterval(videoName: self.video.name, startTime: self.video.startTime, endTime: self.video.endTime) { serverResult in
                            
                            self.uploadingVideoNotification.setLabelWithAnimation(in: self.view, hidden: true)
                            self.uploadProgressView.setViewWithAnimation(in: self.view, hidden: true)
                            self.disableLoadingIndicator()
                            self.nextStepButton.isEnabled = true
                            
                            switch serverResult {
                            case .error(let error):
                                print(error.localizedDescription)
                                self.showErrorConnectingToServerAlert()
                            case .results(let responseCode):
                                if responseCode != 200 {
                                    //showing any alerts here is useless because video at this time is successfully uploaded to the server
                                    //self.showErrorConnectingToServerAlert(title: "Не удалось отправить видео в данный момент")
                                } //else {
                                    //show successfully uploaded notification
                                    DispatchQueue.main.async {
                                        self.nextStepButton.isEnabled = true
                                        self.showVideoUploadSuccessAlert { action in
                                            AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
                                            self.dismiss(animated: true, completion: nil)
                                            if self.isProfileInitiated {
                                                let vc  = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3] as! ProfileViewController
                                                vc.isAppearingAfterUpload = true
                                                self.navigationController?.popToViewController(vc, animated: true)
                                            }
                                            self.presentNewRootViewController()
                                        }
                                    }
                                //}
                            }
                        }
                    } else {
                        print("JSON Error")
                        self.disableLoadingIndicator()
                        //self.doneButton.isEnabled = true
                        self.showVideoUploadSuccessAlert(handler: { (action) in
                            AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
                            self.dismiss(animated: true, completion: nil)
                            if self.isProfileInitiated {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                            self.presentNewRootViewController()
                        })
                    }
                } else {
                    print("Data Error")
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
        playerVC.exitsFullScreenWhenPlaybackEnds = false
        playerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 600))
        playerVC.player?.play()
    }
    
    
    //MARK:- Remove All Video Observers
    private func removeVideoObserver() {
        if let timeObserver = self.videoObserver {
            //removing time obse
            playerVC.player?.removeTimeObserver(timeObserver)
            videoObserver = nil
        }
        if self.videoDidEndPlayingObserver != nil {
            NotificationCenter.default.removeObserver(self)
            videoDidEndPlayingObserver = nil
        }
    }
    
    //MARK:- Add All Video Observers
    private func addVideoObservers() {
        removeVideoObserver()
        
        //MARK:- • time observer
        let interval = CMTimeMake(value: 1, timescale: 600)
        videoObserver = self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            self?.videoRangeSlider.updateProgressIndicator(seconds: currentTime)
        }
        
        //MARK: • Video Did End Playing Observer
        videoDidEndPlayingObserver = NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerVC.player?.currentItem)
    }
    
    @objc private func videoDidEnd() {
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
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
        videoRangeSlider.minSpace = 3.0
        videoRangeSlider.maxSpace = 30.0
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
