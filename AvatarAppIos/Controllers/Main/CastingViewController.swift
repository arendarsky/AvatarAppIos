//
//  CastingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 28.01.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import WebKit
import AVKit
import NVActivityIndicatorView

class CastingViewController: UIViewController {

    //MARK: Properties declaration
    //var urls: [String]?
    private var testURL = "https://devstreaming-cdn.apple.com/videos/app_store/Seriously_Developer_Insight/Seriously_Developer_Insight_hd.mp4"
    private var receivedVideo = Video()
    private var receivedVideoNames = [String]()
    //var serverURL: URL?
    //var player = AVPlayer(url: self.serverURL!)
    private var playerVC = AVPlayerViewController()
    private var loadingIndicator: NVActivityIndicatorView?
    private var imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
    private lazy var backgroundColor = view.backgroundColor
    public lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    
    //@IBOutlet weak var videoWebView: WKWebView!
    @IBOutlet weak var castingView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var starName: UILabel!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var superLikeButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        /*view.addSubview(backdropView)
        if let navigationController = navigationController {
            navigationController.view.addSubview(backdropView)
        }*/
        backdropView.isHidden = true
        
        enableLoadingIndicator()
        setupNavBarRightButton()
        WebVideo.getUrls_Admin { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Server error: \(error)")
                break
            case .results(let result):
                self.receivedVideoNames = result
                if self.receivedVideoNames.count > 0 {
                    self.testURL = "\(domain)/api/video/" + self.receivedVideoNames.removeLast()
                }else{
                    //notificate about empty video list
                }
                print(self.testURL)
                self.receivedVideo = Video(stringUrl: self.testURL, length: 30, startTime: 0, endTime: 30)
                print(self.receivedVideo.url!)
                self.configureVideoView()
                self.configureVideoPlayer(with: self.receivedVideo.url)
            }
        }
        
        
        castingView.dropShadow()
        configureButtons()

    }
    
    //MARK:- View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //playerVC.player?.play()
        //replayButton.isHidden = false
        backdropView.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerVC.player?.pause()
    }
    
    
    //MARK:- Repeat Video
    @IBAction private func repeatButtonPressed(_ sender: Any) {
        replayButton.isHidden = true
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 100))
        playerVC.player?.play()
    }

    //MARK:- Show Full Video
    @IBAction private func showFullVideoButtonPressed(_ sender: Any) {
        playerVC.player?.pause()
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 100))
        let fullScreenPlayer = AVPlayer(url: receivedVideo.url!)
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        
        present(fullScreenPlayerVC, animated: true) {
            fullScreenPlayer.play()
        }
    }
    
    //MARK:- Like & Dislike Button Actions
    @IBAction private func dislikeButtonPressed(_ sender: Any) {
        replayButton.isHidden = true
        enableLoadingIndicator()
        if receivedVideoNames.count > 0 {
            testURL = "\(domain)/api/video/\(receivedVideoNames.removeLast())"
        } else {
            testURL = "https://devstreaming-cdn.apple.com/videos/tutorials/20190910/201gkmn78ytrxz/whats_new_in_sharing/whats_new_in_sharing_hd.mp4"
        }
        receivedVideo.url = URL(string: testURL)
        print(receivedVideoNames.count)
        print(receivedVideo.url)
        enableLoadingIndicator()
        configureVideoPlayer(with: receivedVideo.url)
        //disableLoadingIndicator()
    }
    
    @IBAction private func likeButtonPressed(_ sender: Any) {
        //ternary operator to switch between button colors after pressing it
        //likeButton.tintColor = (likeButton.tintColor == .systemRed ? .label : .systemRed)

        //and something else
        if receivedVideoNames.count > 0 {
            testURL = "\(domain)/api/video/" + receivedVideoNames.removeLast()
        } else {
            testURL = "https://devstreaming-cdn.apple.com/videos/tutorials/20190910/201gkmn78ytrxz/whats_new_in_sharing/whats_new_in_sharing_hd.mp4"
        }
        receivedVideo.url = URL(string: testURL)
        configureVideoPlayer(with: receivedVideo.url)
    }
    
    //MARK: Super Like Button Pressed
    @IBAction func superLikeButtonPressed(_ sender: Any) {
        backdropView.isHidden = false
        
        let destVC = storyboard?.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        destVC.transitioningDelegate = self
        destVC.modalPresentationStyle = .custom
        
        self.present(destVC, animated: true, completion: nil)
    }
    
    //MARK:- Add new video button pressed
    @objc private func rightNavBarButtonPressed() {
        print("button tapped")
        performSegue(withIdentifier: "Upload new video", sender: nil)
    }

}

//MARK:- Presentation Controller Delegate
extension CastingViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FifthSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    
}

extension CastingViewController {
    func hideGrayView() {
        backdropView.isHidden = true
    }
    
}

extension CastingViewController {
    //MARK:- Configure Loading Indicator
    private func enableLoadingIndicator() {
        if loadingIndicator == nil {
            
            let width: CGFloat = 40.0
            let frame = CGRect(x: (videoView.center.x - width/2), y: (videoView.center.y - width/2), width: width, height: width)
            
            loadingIndicator = NVActivityIndicatorView(frame: frame, type: .circleStrokeSpin, color: .white, padding: 8.0)
            //loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: (videoView.center.x - width/2), y: (videoView.center.y - width/2), width: width, height: width))
            //loadingIndicator?.style = .large
            //loadingIndicator?.color = .white
            loadingIndicator?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loadingIndicator?.layer.cornerRadius = 4
            //loadingIndicator?.hidesWhenStopped = true
            

            videoView.addSubview(loadingIndicator!)
        }
        loadingIndicator!.startAnimating()
        loadingIndicator?.isHidden = false
    }
    
    private func disableLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.isHidden = true
    }
    
    //MARK:- Configure Button Views
    private func configureButtons() {
        //likeButton.addBlur()
        //dislikeButton.addBlur()
        likeButton.dropButtonShadow()
        dislikeButton.dropButtonShadow()
        superLikeButton.dropButtonShadow()
        replayButton.isHidden = true
    }
    
    //MARK:- Configure Video View
    private func configureVideoView() {
    
        playerVC.view.frame = videoView.bounds
        //fill video content in frame ⬇️
        playerVC.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVC.view.layer.masksToBounds = true
        playerVC.view.layer.cornerRadius = 12
        playerVC.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        playerVC.view.backgroundColor = .quaternarySystemFill
        playerVC.showsPlaybackControls = false
        
        //MARK:- insert player into videoView
        self.addChild(playerVC)
        playerVC.didMove(toParent: self)
        videoView.insertSubview(playerVC.view, belowSubview: loadingIndicator!)
        //videoView.addSubview(playerVC.view)
        videoView.backgroundColor = .clear
        playerVC.entersFullScreenWhenPlaybackBegins = false
        //playerVC.exitsFullScreenWhenPlaybackEnds = true
        
    }
    
    private func configureVideoPlayer(with url: URL?) {
        if url != nil {
            playerVC.player = AVPlayer(url: url!)
        } else {
            print("invalid url. cannot play video")
            return
        }
        
        //MARK: present video from specified point:
        playerVC.player?.seek(to: CMTime(seconds: receivedVideo.startTime, preferredTimescale: 600))
        playerVC.player?.play()
        
        
        //MARK:- Video Observers
        
        //stop video at specified time. (Can also make progressView from here later)
        let interval = CMTimeMake(value: 1, timescale: 1)
        self.playerVC.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            print(currentTime)
            if currentTime >= (self?.receivedVideo.endTime)! {
                self?.playerVC.player?.pause()
                self?.replayButton.isHidden = false
            } else {
                //self?.disableLoadingIndicator()
                self?.replayButton.isHidden = true
            }
            
            switch self?.playerVC.player?.currentItem?.status{
            case .readyToPlay:
                if let isPlaybackLikelyToKeepUp = self?.playerVC.player?.currentItem?.isPlaybackLikelyToKeepUp {
                    self?.disableLoadingIndicator()
                }else {
                    self?.enableLoadingIndicator()
                }
                
                if let _ = self?.playerVC.player?.currentItem?.isPlaybackBufferEmpty {
                    self?.disableLoadingIndicator()
                }else {
                    self?.enableLoadingIndicator()
                }
                break
            case .failed:
                self?.showErrorConnectingToServerAlert(title: "Не удалось воспроизвести видео", message: "")
                break
            default:
                break
            }
        }
    }
    
    //MARK:- Custom Image inside NavBar
    private func setupNavBarCustomImageView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        //title = "Large Title"

      // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }

        navigationBar.addSubview(imageView)

        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 32),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }
    
    //MARK:- Setting Up Right Button in NavBar
    //preferred solution with UIButton but with some minuses
    private func setupNavBarRightButton() {
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        let rightButton = UIButton()

        rightButton.setBackgroundImage(UIImage(named: "plus128.png"), for: .normal)
        //rightButton.setImage(UIImage(named: "plus32.png"), for: .normal)
        rightButton.imageView?.tintColor = .systemBlue
        rightButton.imageView?.contentMode = .scaleAspectFit
        
        rightButton.addTarget(self, action: #selector(rightNavBarButtonPressed), for: .touchUpInside)
        
        navigationBar.addSubview(rightButton)
        rightButton.tag = 1
        let heightConst: CGFloat = 32
        rightButton.frame = CGRect(x: self.view.frame.width, y: 0, width: heightConst, height: heightConst)
        rightButton.clipsToBounds = true
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightButton.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -16),
            rightButton.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -12),
            rightButton.heightAnchor.constraint(equalToConstant: heightConst),
            rightButton.widthAnchor.constraint(equalTo: rightButton.heightAnchor)
        ])
    
    }
    
}
